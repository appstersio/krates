require 'spec_helper'

describe 'plugin list' do
  it "returns list" do
    run!('krates plugin ls')
    # TODO result check
  end
end
