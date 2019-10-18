require 'spec_helper'

describe 'volume list' do
  before(:each) do
    run "krates volume rm --force testVol"
    run "krates volume rm --force testVol2"
    run! "krates volume create --driver local --scope instance testVol"
    run! "krates volume create --driver local --scope instance testVol2"
  end

  after(:each) do
    run "krates volume rm --force testVol"
    run "krates volume rm --force testVol2"
  end

  it 'lists volumes' do
    k = run! "krates volume list"
    expect(k.out.match(/testVol\s+instance\s+local\s+\d/)).to be_truthy
    expect(k.out.match(/testVol2\s+instance\s+local\s+\d/)).to be_truthy
  end

  context '--quiet' do
    it 'lists volume names' do
      k = run! "krates volume ls -q"
      expect(k.out.lines.sort.map(&:chomp)).to eq ["testVol", "testVol2"]
    end
  end
end
