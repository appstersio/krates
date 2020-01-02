describe 'container logs' do
  it 'inspects a given container' do
    id = container_id('krates-worker')
    expect(id).not_to be_nil

    k = kommando("krates container logs #{id}")
    expect(k.run).to be_truthy
  end

  it 'returns error if container does not exist' do
    k = run("krates container logs invalid-id")
    expect(k.code).to eq(1)
  end
end