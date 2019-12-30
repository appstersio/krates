require 'spec_helper'

describe 'plugin upgrade' do
  context "with older versions of the digitalocean plugin installed" do
    before(:each) do
      run 'krates plugin uninstall digitalocean'
      run! 'krates plugin install --version 0.3.8 digitalocean'
    end

    after(:each) do
      run 'krates plugin uninstall digitalocean'
    end

    it 'upgrades all plugins' do
      k = run!('krates plugin upgrade')
      expect(k.out).to match(/digitalocean/)
      k = run('krates plugin list')
      lines = k.out.split(/[\r\n]/)
      lines.each do |line|
        plugin, version, _ = line.split(/\s+/, 3)
        if plugin == 'digitalocean'
          expect(Gem::Version.new(version) > Gem::Version.new("0.3.8")).to be_truthy
        end
      end
    end
  end

  it 'does nothing if no updates' do
    run!('krates plugin upgrade')
    k = run!('krates plugin upgrade')
    expect(k.out).to match /Nothing upgraded/
  end
end
