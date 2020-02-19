describe GridDomainAuthorizations::Authorize do
  let(:grid) { Grid.create!(name: 'test-grid') }

  let!(:le_private_key) { GridSecret.create!(grid: grid, name: 'LE_PRIVATE_KEY', value: 'LE_PRIVATE_KEY') }

  describe '#validate' do
    context 'without a valid LE registration' do
      before do
        le_private_key.destroy
      end

      it 'fails validation' do
        outcome = described_class.validate(grid: grid, domain: 'example.com')

        expect(outcome).not_to be_success
        expect(outcome.errors.message).to eq 'le_registration' => "Let's Encrypt registration missing"
      end
    end

    describe 'authorization_type=dns-01' do
      it 'fails with a linked service' do
        outcome = described_class.validate(grid: grid, domain: 'example.com',
          authorization_type: 'dns-01',
          linked_service: 'test/test',
        )

        expect(outcome).not_to be_success
        expect(outcome.errors.message).to eq 'linked_service' => "Service link cannot be given for the dns-01 authorization type"
      end
    end

    describe 'authorization_type=http-01' do
      it 'fails without a linked service' do
        outcome = described_class.validate(grid: grid, domain: 'example.com',
          authorization_type: 'http-01',
        )

        expect(outcome).not_to be_success
        expect(outcome.errors.message).to eq 'linked_service' => "Service link needs to be given for the http-01 authorization type"
      end

      context 'for a linked service without exposed ports' do
        let!(:grid_service) { GridService.create(grid: grid, name: 'web', image_name: 'web:latest') }

        it 'fails validation with missing port 80' do
          outcome = described_class.validate(grid: grid, domain: 'example.com',
            authorization_type: 'http-01',
            linked_service: 'null/web',
          )

          expect(outcome).not_to be_success
          expect(outcome.errors.message).to eq 'linked_service' => "Linked service does not have port 80 open"
        end
      end

      context 'for a linked service with network_mode=host' do
        let!(:grid_service) { GridService.create(grid: grid, name: 'web', image_name: 'web:latest',
          net: 'host',
        ) }

        it 'passes validation' do
          outcome = described_class.validate(grid: grid, domain: 'example.com',
            authorization_type: 'http-01',
            linked_service: 'null/web',
          )

          expect(outcome).to be_success
        end
      end

      context 'for a linked service exposing port 80' do
        let!(:grid_service) { GridService.create(grid: grid, name: 'web', image_name: 'web:latest',
          ports: [ { 'node_port' => 80 } ],
        ) }

        it 'passes validation' do
          outcome = described_class.validate(grid: grid, domain: 'example.com',
            authorization_type: 'http-01',
            linked_service: 'null/web',
          )

          expect(outcome).to be_success
        end
      end
    end
  end

  let(:acme_client) { instance_double(Acme::Client) }
  let(:finalize_url) { 'https://acme-staging-v02.api.letsencrypt.org/directory/finalize-order/6H2x8Bin-qxPnVerW-k4C-2nlYzbW3SWpBlw-o--_Kg' }

  before(:each) do
    allow(subject).to receive(:acme_client).and_return(acme_client)
  end

  let(:acme_order) { double(
    status: 'pending',
    expires: Time.now + 300,
    finalize_url: finalize_url,
    authorizations: [
      double(
        expires: Time.now + 300,
        dns01: double(
          record_name: '_acme-challenge',
          record_type: 'TXT',
          record_content: '123456789',
          to_h: {}
        )
      )
    ],
  ) }

  describe 'authorization_type=dns-01' do
    subject { described_class.new(grid: grid, domain: 'example.com',
      authorization_type: 'dns-01',
    ) }

    it 'requests domain authorization and creates model' do
      expect(acme_client).to receive(:new_order).with(identifiers: ['example.com']).and_return(acme_order)

      expect(outcome = subject.run).to be_success

      authz = GridDomainAuthorization.find_by(domain: 'example.com')

      expect(authz).to_not be_nil
      expect(authz).to eq outcome.result
      expect(authz.domain).to eq 'example.com'
      expect(authz.authorization_type).to eq 'dns-01'
      expect(authz.challenge_opts).to eq(
        'record_name' => '_acme-challenge',
        'record_type' => 'TXT',
        'record_content' => '123456789',
        'finalize_url' => finalize_url
      )
    end

    it 'fails if LE does not offer a dns-01 challenge' do
      expect(acme_client).to receive(:new_order).with(identifiers: ['example.com']).and_return(double(authorizations: [double(dns01: nil)]))

      expect {
        outcome = subject.run

        expect(outcome).to_not be_success
        expect(outcome.errors.message).to eq 'challenge' => "LE did not offer any dns-01 challenge"
      }.not_to change{GridDomainAuthorization.count}
    end

    context 'with an existing authz' do
      let!(:authz) {
        challenge_opts = {
          'record_name' => '_acme-challenge',
          'record_content' => '1234567890'
        }
        GridDomainAuthorization.create!(grid: grid, domain: 'example.com', challenge: {}, challenge_opts: challenge_opts)
      }

      it 'replaces the authz' do
        expect(acme_client).to receive(:new_order).with(identifiers: ['example.com']).and_return(acme_order)

        expect {
          expect(outcome = subject.run).to be_success
        }.to change{GridDomainAuthorization.find_by(domain: 'example.com')}.from(authz)
      end
    end
  end

  describe 'authorization_type=http-01' do
    let(:challenge_token) { 'LoqXcYV8q5ONbJQxbmR7SCTNo3tiAXDfowyjxAjEuX0' }
    let(:challenge_content) { 'LoqXcYV8q5ONbJQxbmR7SCTNo3tiAXDfowyjxAjEuX0.9jg46WB3rR_AHD-EBXdN7cBkH1WOu0tA3M9fm21mqTI' }
    let(:expires_at) { Time.now + 300 }
    let(:acme_order) { double(
      status: 'pending',
      expires: expires_at,
      finalize_url: finalize_url,
      authorizations: [
        double(
          expires: expires_at,
          http: double(
            token: challenge_token,
            file_content: challenge_content,
            to_h: {}
          ),
        )
      ]
    ) }

    context 'with a linked service' do
      let(:linked_service) { GridService.create(grid: grid, name: 'lb', image_name: 'krates/lb:latest',
        ports: [ { 'node_port' => 80 } ],
      ) }

      subject {
        linked_service
        described_class.new(grid: grid, domain: 'example.com',
          authorization_type: 'http-01',
          linked_service: 'null/lb',
        )
      }

      it 'requests domain authorization and creates model' do
        expect(acme_client).to receive(:new_order).with(identifiers: ['example.com']).and_return(acme_order)

        expect(outcome = subject.run).to be_success

        authz = GridDomainAuthorization.find_by(domain: 'example.com')

        expect(authz).to_not be_nil
        expect(authz).to eq outcome.result
        expect(authz.domain).to eq 'example.com'
        expect(authz.authorization_type).to eq 'http-01'
        expect(authz.challenge_opts).to eq(
          'token' => challenge_token,
          'content' => challenge_content,
          'finalize_url' => finalize_url
        )
      end

      it 'fails if LE does not offer a http-01 challenge' do
        expect(acme_client).to receive(:new_order).with(identifiers: ['example.com']).and_return(double(authorizations: [double(http: nil)]))

        expect {
          outcome = subject.run

          expect(outcome).to_not be_success
          expect(outcome.errors.message).to eq 'challenge' => "LE did not offer any http-01 challenge"
        }.not_to change{GridDomainAuthorization.count}
      end
    end
  end
end
