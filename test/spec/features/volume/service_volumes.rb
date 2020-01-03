require 'spec_helper'
require 'json'
require_relative 'common'

describe 'service volumes' do
  include Common

  after(:each) do
    run "krates service rm --force null/redis"
    run "krates volume rm --force testVol"
  end

  it 'service uses a volume' do
    run! "krates volume create --driver local --scope instance testVol"
    run! "krates service create -v testVol:/data redis redis:alpine"
    run! "krates service deploy redis"

    mount = container_mounts(find_container('redis-1')).find { |m| m['Name'] =~ /testVol/}
    expect(mount).not_to be_nil
    expect(mount['Name']).to eq("redis.testVol-1")
    expect(mount['Destination']).to eq('/data')
  end

  it 'volume cannot be removed when still used by a service' do
    run! "krates volume create --driver local --scope instance testVol"
    run! "krates service create -v testVol:/data redis redis:alpine"
    k = run "krates volume rm --force testVol"
    expect(k.code).not_to eq(0)
  end

end
