require 'spec_helper'
# NOTE: These tests are obsolete but might be useful for future reference
describe 'app subcommand', :broken => true do
  context 'with the app-command plugin', subcommand: :app do
    describe 'app remove', subcommand: :app do
      before do
        with_fixture_dir('app/simple') do
          k = run('krates app rm --force')
          sleep 1 if k.code.zero?
        end
      end

      it 'removes a deployed app' do
        with_fixture_dir('app/simple') do
          run!('krates app deploy')
          run!('krates app rm --force')
          sleep 1
          k = run!('krates service ls')
          %w(lb nginx redis).each do |service|
            expect(k.out).not_to match(/simple-#{service}/)
          end
        end
      end
    end
  end
end
