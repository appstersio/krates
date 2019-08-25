describe 'vault remove' do
  after(:each) do
    run 'krates vault rm --force foo'
    run 'krates vault rm --force foo0'
    run 'krates vault rm --force foo1'
  end

  it 'removes a vault key' do
    run! 'krates vault write foo bar'
    run! 'krates vault rm --force foo'
  end

  it 'removes multiple vault keys' do
    2.times do |i|
      run! "krates vault write foo#{i} bar"
    end
    run! 'krates vault rm --force foo0 foo1'
  end
end
