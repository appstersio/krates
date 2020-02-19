require 'timeout'

require_relative 'common'
require_relative '../../services/logging'

module GridCertificates
  class RequestCertificate < Mutations::Command
    include Common
    include Logging
    include WaitHelper

    required do
      model :grid, class: Grid
      array :domains do
        string
      end
    end

    def validate
      self.domains.each do |domain|
        domain_authz = get_authz_for_domain(self.grid, domain)

        if domain_authz
          if domain_authz.authorization_type == 'dns-01'
            # Check that the expected DNS record is already in place
            unless validate_dns_record(domain, domain_authz.challenge_opts['record_content'])
              add_error(:dns_record, :invalid, "Expected DNS record not present for domain #{domain}")
            end
          end
        else
          add_error(:authorization, :not_found, "Domain authorization not found for domain #{domain}")
        end

      end
    end

    def verify_domain(domain)
      domain_authorization = get_authz_for_domain(self.grid, domain)
      challenge = le_client.challenge(url: domain_authorization.challenge['url'])
      if domain_authorization.state == :created
        info "requesting validation for domain #{domain}"
        success = challenge.request_validation
        if success
          domain_authorization.state = :requested
          domain_authorization.save
        else
          add_error(:request_verification, :failed, "Requesting verification failed")
          return
        end
      end

      wait_until!("domain verification for #{domain} is valid", interval: 1, timeout: 30, threshold: 10) {
        challenge.reload
        challenge.status != 'pending'
      }

      domain_authorization.expires_at = nil # XXX: old version of acme-client does not update authorization expiration

      case challenge.status
      when 'valid'
        domain_authorization.state = :validated
      when 'invalid'
        domain_authorization.state = :error
        add_error(:challenge, :invalid, challenge.error['detail'])
      end

      domain_authorization.save
    rescue Timeout::Error => exc
      warn exc
      add_error(:challenge_verify, :timeout, "Challenge validation timeout: #{exc}")
    rescue Acme::Client::Error => exc
      error exc
      add_error(:acme_client, :error, exc.message)
    end

    def has_errors?
      return true if @errors && @errors.size > 0
      false
    end

    def execute

      self.domains.each do |domain|
        verify_domain(domain)
      end

      # some domain verifications has failed, errors already added
      return if has_errors?

      domain_authorization = self.get_authz_for_domain(self.grid, self.domains.first)

      # Generate a new Certificate Signing Request
      csr = Acme::Client::CertificateRequest.new(names: self.domains)
      # Finalize our order with LetsEncrypt
      order = le_client.finalize(url: domain_authorization.challenge_opts['finalize_url'], csr: csr)

      # Poll for the order status changes
      wait_until!("order with LetsEncrypt is completed", interval: 1, timeout: 30, threshold: 10) {
        order.reload
        order.status != 'processing'
      }

      # TODO: Handle order status other than success
      certificate = OpenSSL::X509::Certificate.new(order.certificate)
      # Partition order's certificate by \n\n since tail of the partition contains chain
      parts = order.certificate.partition(/\n\n/)
      chain_as_pem = parts[2]

      return upsert_certificate(Certificate.new(
        grid: self.grid,
        subject: self.domains[0],
        alt_names: self.domains[1..-1],
        valid_until: certificate.not_after,
        private_key: csr.private_key.to_pem,
        certificate: certificate.to_pem,
        chain: chain_as_pem
      ))

    rescue Acme::Client::Error => exc
      error exc
      add_error(:acme_client, :error, exc.message)
    end

    def le_client
      @le_client ||= acme_client(self.grid)
    end
  end
end
