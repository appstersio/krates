require 'spec_helper'

describe 'plugin install' do
  after(:each) do
    run('krates plugin uninstall digitalocean')
  end

  it 'installs a plugin' do
    run!('krates plugin install digitalocean')
    k = run!('krates plugin ls')
    expect(k.out).to match(/digitalocean/)
  end

  it 'installs a plugin from a URL' do
    run!('krates plugin install https://rubygems.org/downloads/krates-plugin-digitalocean-0.3.9.gem')
    k = run!('krates plugin ls')
    expect(k.out).to match(/digitalocean/)
  end

  it 'installs a plugin from a file' do
    run!('gem fetch krates-plugin-digitalocean --version 0.3.9')
    run!('krates plugin install krates-plugin-digitalocean-0.3.9.gem')
    File.unlink('krates-plugin-digitalocean-0.3.9.gem')
    k = run!('krates plugin ls')
    expect(k.out).to match(/digitalocean/)
  end

  it 'attempts to upgrade a plugin' do
    run!('krates plugin install digitalocean')
    k = run!('krates plugin ls')
    expect(k.out).to match(/digitalocean/)
    k = run!('krates plugin install digitalocean')
    expect(k.out).to match(/Upgrad/)
  end
end
