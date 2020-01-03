require 'spec_helper'

describe 'etcd get' do
  after(:each) do
    run 'krates etcd rm --recursive --force /e2e'
  end

  it 'sets a value to a new key' do
    run! 'krates etcd set /e2e/test yes'
    k = run! 'krates etcd get /e2e/test'
    expect(k.out.strip).to eq('yes')
  end

  it 'sets a value to an existing key' do
    run! 'krates etcd set /e2e/test foo'
    run! 'krates etcd set /e2e/test yes'
    k = run! 'krates etcd get /e2e/test'
    expect(k.out.strip).to eq('yes')
  end
end
