require 'spec_helper'

describe 'stack remove' do
  after(:each) do
    run 'krates stack rm --force simple'
  end

  it "removes a stack" do
    with_fixture_dir("stack/simple") do
      run! 'krates stack install --no-deploy'
    end
    run! "krates stack rm --force simple"
    k = run "krates stack show simple"
    expect(k.code).not_to eq(0)
  end

  it "removes multiple stacks" do
    with_fixture_dir("stack/simple") do
      run! 'krates stack install --no-deploy'
      run! 'krates stack install --no-deploy --name simple2'
    end
    run! "krates stack rm --force simple simple2"
    k = run "krates stack show simple2"
    expect(k.code).not_to eq(0)
  end

  it "prompts without --force" do
    with_fixture_dir("stack/simple") do
      run! 'krates stack install --no-deploy'
    end
    k = kommando 'krates stack rm simple', timeout: 5
    k.out.on "To proceed, type" do
      sleep 0.5
      k.in << "simple\r"
    end
    k.run
    expect(k.code).to eq(0)
  end

  context "for a stack that has dependencies" do
    before do
      with_fixture_dir("stack/depends") do
        run! 'krates stack install'
      end
    end

    after do
      run 'krates stack rm --force twemproxy-twemproxy-redis_from_registry'
      run 'krates stack rm --force twemproxy-redis_from_yml'
      run 'krates stack rm --force twemproxy'
    end

    it 'removes all the dependencies' do
      k = run! 'krates stack ls -q'
      expect(k.out.split(/[\r\n]/)).to match array_including(
        'twemproxy-redis_from_registry',
        'twemproxy-redis_from_yml',
        'twemproxy'
      )

      run! 'krates stack rm --force twemproxy'

      k = run! 'krates stack ls -q'
      expect(k.out).not_to match /twemproxy-redis_from_registry/
      expect(k.out).not_to match /twemproxy-redis_from_yml/
      expect(k.out).not_to match /twemproxy/
    end
  end
end
