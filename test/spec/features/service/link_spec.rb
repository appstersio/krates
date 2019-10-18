describe 'service link' do
  context 'with a test-1 service' do
    before do
      run! "krates service create test-1 redis:3.0"
    end

    after do
      run("krates service rm --force test-1")
    end

    context 'with a test-2 service' do
      before do
        run! "krates service create test-2 redis:3.0"
      end

      after do
        run "krates service unlink test-1 test-2"
        run "krates service rm --force test-2"
      end

      it 'links service to target' do
        run! "krates service link test-1 test-2"
        k = run! "krates service show test-1"
        expect(k.out.match(/^\s+- test-2\s*$/)).to be_truthy
      end
    end

    context 'with a simple stack' do
      before do
        with_fixture_dir("stack/simple") do
          run! 'krates stack install --no-deploy'
        end
      end

      after do
        run! 'krates stack rm --force simple'
      end
      after do
        run! 'krates service unlink test-1 simple/redis'
      end

      it 'links service to stack service' do
        run! "krates service link test-1 simple/redis"
        k = run! "krates service show test-1"
        expect(k.out.match(/^\s+\- simple\/redis\s*$/)).to be_truthy
      end
    end

    context 'with a simple stack that has existing links to service' do
      before do
        with_fixture_dir("stack/links") do
          run! 'krates stack install --no-deploy links.yml'
        end
      end

      after do
        run! 'krates stack rm --force simple'
      end
      after do
        run! 'krates service unlink simple/bar test-1'
      end

      it 'links stack service with existing links to service' do
        run! "krates service link simple/bar test-1"
        k = run! "krates service show simple/bar"
        expect(k.out.match(/^\s+\- test-1\s*$/)).to be_truthy
      end
    end

    it 'returns error if target does not exist' do
      k = run "krates service link test-1 foo"
      expect(k.code).not_to eq(0)
    end
  end
end
