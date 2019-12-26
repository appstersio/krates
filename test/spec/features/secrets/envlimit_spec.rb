require 'spec_helper'

describe 'secret env size limits' do
  context 'with a deployed stack' do
    before(:each) do
      run 'kontena stack rm --force secrets-envsize'
      with_fixture_dir("secrets") do
        run! 'kontena stack install -v secret_count=64 envsize.yaml'
      end
    end

    after(:each) do
      run 'kontena stack rm --force secrets-envsize'
    end

    it 'fails to upgrade with too many secrets, without killing the deployed container' do
      cid = container_id('secrets-envsize.test-1')

      with_fixture_dir("secrets") do
        expect {
          `kontena stack upgrade -v secret_count=128 secrets-envsize envsize.yaml`
        }.to output(/Kontena::Models::ServicePod::ConfigError: Env SECRETS is too large at \d+ bytes/).to_stderr_from_any_process
      end

      # still running?
      cinfo = inspect_container(cid)
      expect(cinfo['State']['Status']).to eq 'running'
    end
  end
end
