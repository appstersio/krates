require 'spec_helper'

describe 'plugin search' do
  it 'lists available plugins' do
    k = run!('krates plugin search')
    expect(k.out).to match(/digitalocean/)
  end
end
