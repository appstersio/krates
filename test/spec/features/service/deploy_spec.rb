require 'spec_helper'

describe 'service deploy' do
  it 'deploys a service' do
    run!("krates service create test-1 redis:3.0")
    run!("krates service deploy test-1")
    run!("krates service rm --force test-1")
  end

  context "For a service that fails to deploy" do
    before do
      run!("krates service create -v /dev/null/wtf:/dev/wtf test-fail redis")
    end

    after do
      run!("krates service rm --force test-fail")
    end

    it "fails to deploy with an error" do
      k = run("krates service deploy test-fail")

      expect(k.code).not_to eq(0), k.out

      expect(k.out).to match /halting deploy of .+, one or more instances failed/
      expect(k.out).to match /Failed to deploy instance .+ to node .+: GridServiceInstanceDeployer::ServiceError: .*stat \/dev\/null\/wtf: not a directory/
    end
  end
end
