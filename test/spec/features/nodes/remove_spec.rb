describe 'node remove' do

  after(:each) do
    run 'krates node rm --force rm-test-1 rm-test-2'
  end

  it 'removes a node' do
    run! 'krates node create rm-test-1'
    # Capture stdout of the command
    k = run! 'krates node rm --force rm-test-1'
    # Assert expectations are met
    expect(k.out.lines).not_to include 'rm-test-1'
  end

  it 'removes multiple nodes' do
    run! 'krates node create rm-test-1'
    run! 'krates node create rm-test-2'
    # Capture stdout of the command
    k = run! 'krates node rm --force rm-test-1 rm-test-2'
    # Assert expectations are met
    expect(k.out.lines).not_to include 'rm-test-1'
    expect(k.out.lines).not_to include 'rm-test-2'
  end
end
