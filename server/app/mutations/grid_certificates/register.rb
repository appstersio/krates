require 'acme-client'
require 'openssl'

require_relative 'common'
require_relative '../../services/logging'

module GridCertificates
  class Register < Mutations::Command
    include Common
    include Logging

    required do
      model :grid, class: Grid
      string :email
    end

    def execute
      account = acme_client(self.grid).new_account(contact: "mailto:#{email}", terms_of_service_agreed: true)
      info "Registered new account '#{account.contact}' with status '#{account.status}' and kid '#{account.url}'"
    rescue Acme::Client::Error => exc
      add_error(:acme, :error, exc.message)
    end
  end
end
