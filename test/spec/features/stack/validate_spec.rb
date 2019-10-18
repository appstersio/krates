describe 'stack validate' do
  context 'keywords' do
    context 'entrypoint' do
      it 'sets stack entrypoint' do
        with_fixture_dir("stack/keywords") do
          k = run! 'krates stack validate --format=api-json entrypoint.yml'
          data = JSON.load(k.out)

          expect(data).to match hash_including(
            'services' => a_collection_containing_exactly(
              hash_including(
                'name' => 'redis',
                'entrypoint' => 'foo',
              ),
              hash_including(
                'name' => 'redis2',
                'entrypoint' => 'foo2',
              )
            ),
          )
        end
      end
    end
  end
  context 'service_link' do
    after(:each) do
      run 'krates stack rm --force simple'
    end

    it "allows to select matching service" do
      with_fixture_dir("stack/simple") do
        run! 'krates stack install --no-deploy'
      end
      with_fixture_dir("stack/service_link") do
        k = kommando 'krates stack validate --online', timeout: 5
        k.out.on "Select link" do
          k.in << "\r"
        end
        k.run
        expect(k.code).to eq(0)
        expect(k.out.match(/links\:\r\n\s+- simple\/redis/)).to be_truthy
      end
    end

    it "returns an error if link does not exist" do
      with_fixture_dir("stack/service_link") do
        k = run 'krates stack validate', timeout: 5
        expect(k.code).not_to eq(0)
        expect(k.out.match(/validation failed/i)).to be_truthy
      end
    end
  end
end
