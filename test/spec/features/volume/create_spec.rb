require 'spec_helper'

describe 'volume create' do
  after(:each) do
    run "krates volume rm --force testVol"
  end

  it 'creates a volume' do
    run! "krates volume create --driver local --scope instance testVol"
    k = run! "krates volume ls"
    expect(k.out.match(/testVol/)).to be_truthy
  end

  it 'fails to create volume without driver' do
    k = run "krates volume create --scope instance testVol"
    expect(k.code).not_to eq(0)
  end


  it 'fails to create volume without scope' do
    k = run "krates volume create --driver local testVol"
    expect(k.code).not_to eq(0)
  end


  it 'removes a volume' do
    run! "krates volume create --driver local --scope instance testVol"
    run! "krates volume rm --force testVol"
    k = run! "krates volume ls"
    expect(k.out.match(/testVol/)).to be_falsey
  end
end
