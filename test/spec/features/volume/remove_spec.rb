describe 'volume remove' do
  after(:each) do
    run 'krates volume rm --force test-volume'
    run 'krates volume rm --force test-volume0'
    run 'krates volume rm --force test-volume1'
  end

  it 'removes a volume' do
    run! 'krates volume create --driver local --scope grid test-volume'
    run! 'krates volume rm --force test-volume'
  end

  it 'removes multiple volumes' do
    2.times do |i|
      run! "krates volume create --driver local --scope grid test-volume#{i}"
    end
    run! 'krates volume rm --force test-volume0 test-volume1'
  end
end
