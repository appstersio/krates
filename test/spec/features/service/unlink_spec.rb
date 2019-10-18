describe 'service unlink' do
  after(:each) do
    %w(test-1 test-2).each do |s|
      run "krates service rm --force #{s}"
    end
    run "krates stack rm --force simple"
  end

  it 'unlinks service to target' do
    run! "krates service create test-1 redis:3.0"
    run! "krates service create test-2 redis:3.0"
    run! "krates service link test-1 test-2"
    run! "krates service unlink test-1 test-2"
    k = run! "krates service show test-1"
    expect(k.out.match(/^\s+- test-2\s*$/)).to be_falsey
  end

  it 'unlinks service from stack with existing links' do
    with_fixture_dir("stack/links") do
      run 'krates stack install --no-deploy links.yml'
    end
    run! "krates service create test-1 redis:3.0"
    run! "krates service link simple/bar test-1"
    k = run! "krates service show simple/bar"
    expect(k.out.match(/^\s+\- test-1\s*$/)).to be_truthy
    k = run! "krates service unlink simple/bar test-1"
    expect(k.out.match(/^\s+\- test-1\s*$/)).to be_falsey
  end

  it 'returns error if target does not exist' do
    run! "krates service create test-1 redis:3.0"
    k = run "krates service unlink test-1 foo"
    expect(k.code).not_to eq(0)
  end
end
