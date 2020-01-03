require 'spec_helper'

describe 'service logs' do
  before(:all) do
    run("krates service create --log-driver journald --instances 2 test-1 redis:3.0")
    run("krates service deploy test-1")
    sleep 5
  end

  after(:all) do
    run("krates service rm --force test-1")
  end

  it 'displays all service instance logs' do
    k = kommando("krates service logs test-1")
    expect(k.run).to be_truthy
    expect(k.out.scan(/PID: 1/).size).to eq(2)
  end

  context 'when passing instance number' do
    it 'diplays logs only from related service instance' do
      k = kommando("krates service logs -i 1 test-1")
      expect(k.run).to be_truthy
      expect(k.out.scan(/PID: 1/).size).to eq(1)
    end
  end
end
