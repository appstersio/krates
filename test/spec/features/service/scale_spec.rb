require 'spec_helper'

describe 'service scale' do
  it 'scales a service' do
    run("krates service create test-1 redis:3.0")
    k = kommando("krates service deploy test-1")
    expect(k.run).to be_truthy
    k = kommando("krates service scale test-1 3")
    expect(k.run).to be_truthy

    run("krates service rm --force test-1")
  end
end
