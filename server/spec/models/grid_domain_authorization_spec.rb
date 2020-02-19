describe GridDomainAuthorization do
  it { should have_fields(:domain).of_type(String)}
  it { should have_fields(:challenge, :challenge_opts).of_type(Hash) }

  let(:grid) { Grid.create!(name: 'test-grid') }

  subject {
    described_class.create!(grid: grid,
      state: :created,
      domain: 'example.com',
      authorization_type: 'dns-01',
    )
  }

  describe 'without any linked service' do
    it 'is not deployable' do
      expect(subject).to_not be_deployable
    end
  end

  context 'with a linked service' do
    let(:lb_service) { GridService.create!(grid: grid, name: 'lb',
        image_name: 'krates/lb:latest'
    ) }

    subject {
      described_class.create!(grid: grid,
        state: :created,
        domain: 'example.com',
        authorization_type: 'http-01',
        grid_service: lb_service,
      )
    }
  end
end
