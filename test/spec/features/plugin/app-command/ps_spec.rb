require 'spec_helper'
# NOTE: These tests are obsolete but might be useful for future reference
describe 'app subcommand', :broken => true do
  context 'with the app-command plugin', subcommand: :app do
    describe 'app ps', subcommand: :app do
      it "returns list" do
        with_fixture_dir('app/simple') do
          k = run!('krates app ps')
          %w(lb nginx redis).each do |service|
            expect(k.out).to match(/#{service}/)
          end
        end
      end
    end
  end
end
