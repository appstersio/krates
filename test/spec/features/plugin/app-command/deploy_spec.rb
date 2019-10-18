require 'spec_helper'
# NOTE: These tests are obsolete but might be useful for future reference
describe 'app subcommand', :broken => true do
  context 'with the app-command plugin', subcommand: :app do
    describe 'app deploy' do
      it 'deploys a simple app' do
        with_fixture_dir('app/simple') do
          k = run('krates app deploy')
          k.wait
          expect(k.code).to eq(0)
          
          # hack to ensure that the app services get cleaned up before the next spec runs
          run! 'krates service update --stop-timeout=1s simple-lb'
          run! 'krates service deploy --force simple-lb'

          k = run!('krates service ls')
          %w(lb nginx redis).each do |service|
            expect(k.out).to match(/simple-#{service}/)
          end
          run!('krates app rm --force')
        end
      end
    end
  end
end
