require 'spec_helper'
require 'json'

describe 'service stop' do
  before(:each) do
    run!("krates service create test-1 redis:3.0")
    run!("krates service create test-2 redis:3.0")
    run!("krates service deploy test-1")
  end

  after(:each) do
    run("krates service rm --force test-1")
    run("krates service rm --force test-2")
  end

  it 'stops running service' do
    k = kommando("krates service stop test-1")
    expect(k.run).to be_truthy
    sleep 1
    k = run("krates service show test-1")
    expect(k.out.scan('desired_state: stopped').size).to eq(1)
    expect(k.out.scan('status: stopped').size).to eq(1)
  end

  it 'stops initialized service' do
    k = kommando("krates service stop test-2")
    expect(k.run).to be_truthy
    sleep 1
    k = run("krates service show test-2")
    expect(k.out.scan('desired_state: stopped').size).to eq(1)
  end

  it 'stops multiple services' do
    run! "krates service stop test-1 test-2"
    sleep 1
    k = run("krates service show test-1")
    expect(k.out.scan('desired_state: stopped').size).to eq(1)
    k = run("krates service show test-2")
    expect(k.out.scan('desired_state: stopped').size).to eq(1)
  end

  context 'stop_signal set' do
    after(:each) do
      run "krates stack rm --force simple"
    end

    it 'sets StopSignal for container' do
      with_fixture_dir("stack/stop_signal") do
        run! 'krates stack install --deploy'
      end

      id = container_id('simple.app-1')
      k = run! "krates container inspect #{id}"
      expect(JSON.parse(k.out).dig('Config', 'StopSignal')).to eq('SIGINT')
    end
  end
end
