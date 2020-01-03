require 'spec_helper'

describe 'plugin uninstall' do
  context 'with the digitalocean plugin installed' do
    before(:each) do
      run! 'krates plugin install digitalocean'
    end

    it 'removes installed plugin' do
      run! 'krates plugin uninstall digitalocean'

      k = run! 'krates plugin ls'
      expect(k.out).to_not match(/digitalocean/)
    end
  end
end
