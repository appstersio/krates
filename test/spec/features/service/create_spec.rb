describe 'service create' do

  after(:each) do
    run 'krates service rm --force create-test'
  end

  it 'creates a service' do
    run! 'krates service create create-test redis:3-alpine'
    # TODO result check
  end
end
