require 'spec_helper'

describe 'stack upgrade' do
  context 'from file' do
    before(:each) do
      run 'krates stack rm --force redis'
      run 'krates stack rm --force links-external-linked'
      with_fixture_dir("stack/upgrade") do
        run 'krates stack install version1.yml'
      end
    end

    after(:each) do
      run 'krates stack rm --force redis'
      run 'krates stack rm --force links-external-linked'
      sleep 5
    end

    it 'upgrades a stack' do
      k = run! 'krates service show redis/redis'
      expect(k.out).to match /image: redis:3.0.7-alpine/

      with_fixture_dir("stack/upgrade") do
        run! 'krates stack upgrade --force --reuse-values redis version2.yml'
      end

      k = run! 'krates service show redis/redis'
      expect(k.out).to match /image: redis:3.2.8-alpine/
    end

    it 'prompts if the stack is different' do
      with_fixture_dir("stack/upgrade") do
        k = kommando 'krates stack upgrade redis different.yml'
        k.out.on /Are you sure/ do
          k.in << "n\r"
        end
        k.run
        expect(k.code).to eq(1)
        expect(uncolorize(k.out)).to match /redis from test\/redis to test\/notredis.*Aborted command/m
      end
    end
  end

  context "for a stack that is linked to externally" do
    before(:each) do
      run 'krates service rm --force external-linking-service'
      run 'krates stack rm --force links-external-linked'
      with_fixture_dir("stack/links") do
        run! 'krates stack install external-linked_1.yml'
      end
    end

    after(:each) do
      run 'krates service rm --force external-linking-service'
      run 'krates stack rm --force links-external-linked'
      sleep 5
    end

    it 'fails to upgrade if linked' do
      run! 'krates service create --link links-external-linked/bar external-linking-service redis'

      with_fixture_dir("stack/links") do
        k = run 'krates stack upgrade --force --no-deploy links-external-linked external-linked_2.yml'
        expect(k.code).to_not eq(0), k.out
        expect(k.out).to match /Cannot delete service that is linked to another service/
      end
    end

    it 'fails to deploy if linked' do
      with_fixture_dir("stack/links") do
        run! 'krates stack upgrade --force --no-deploy links-external-linked external-linked_2.yml'
      end

      run! 'krates service create --link links-external-linked/bar external-linking-service redis'

      with_fixture_dir("stack/links") do
        k = run 'krates stack deploy links-external-linked'
        expect(k.code).to_not eq(0), k.out
        expect(k.out).to match /deploy failed/
      end
    end
  end

  context "for a stack that has dependencies" do
    after do
      run('krates stack ls -q').out.split(/[\r\n]/).each do |stack|
        run "krates stack rm --force #{stack}"
      end
      sleep 5
    end

    # NOTE: At some point registry stopped accepting unauthenticated requests.
    # Therefore first step is to mark these tests as :broken,
    # and second step is to adjust the code to use Github as the source of predefined & usable stacks.
    context "when a new dependency is added", :broken => true do
      it 'installs the added stack' do
        with_fixture_dir("stack/depends") do
          run! 'krates stack install'
        end

        with_fixture_dir("stack/depends/monitor_added") do
          run! 'krates stack upgrade --force twemproxy'
        end

        k = run! 'krates stack ls -q'
        expect(k.out).to match /twemproxy-redis_from_yml-monitor/
      end
    end

    # NOTE: At some point registry stopped accepting unauthenticated requests.
    # Therefore first step is to mark these tests as :broken,
    # and second step is to adjust the code to use Github as the source of predefined & usable stacks.
    context "when a dependency is removed", :broken => true do
      it 'removes the stack' do
        with_fixture_dir("stack/depends/monitor_added") do
          run! 'krates stack install'
        end

        k = run! 'krates stack ls -q'
        expect(k.out).to match /twemproxy-redis_from_yml-monitor/

        with_fixture_dir("stack/depends/monitor_removed") do
          run! 'krates stack upgrade --force twemproxy'
        end

        k = run! 'krates stack ls -q'
        expect(k.out).not_to match /twemproxy-redis_from_yml-monitor/
      end
    end

    # NOTE: At some point registry stopped accepting unauthenticated requests.
    # Therefore first step is to mark these tests as :broken,
    # and second step is to adjust the code to use Github as the source of predefined & usable stacks.
    context "when a dependency is replaced", :broken => true do
      it 'removes the stack' do
        with_fixture_dir("stack/depends") do
          run! 'krates stack install'
        end

        k = run! 'krates stack show twemproxy-redis_from_yml'
        expect(k.out).to match /stack: test\/redis/

        with_fixture_dir("stack/depends/second_redis_replaced") do
          run! 'krates stack upgrade --force twemproxy'
        end

        k = run! 'krates stack show twemproxy-redis_from_yml'
        expect(k.out).to match /stack: kontena\/redis/
      end
    end
  end
end
