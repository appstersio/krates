describe Kontena::Workers::ContainerCleanupWorker do
    let(:subject) { described_class.new(false) }
    let(:weave_exec_a) { double() }

    before(:each) { Celluloid.boot }
    after(:each) { Celluloid.shutdown }

    describe '#cleanup_containers' do
      it 'skips containers exited less than 5 minutes ago' do
        expect(Docker::Container).to receive(:all).with(all: true, filters: "{\"status\":[\"exited\"]}").and_return([weave_exec_a])
        expect(weave_exec_a).to receive(:info).and_return({'Status' => 'Exited (0) 3 minutes ago'})
        expect(weave_exec_a).not_to receive(:remove)

        subject.cleanup_containers
      end

      it 'removes containers exited at the grace period mark' do
        expect(Docker::Container).to receive(:all).with(all: true, filters: "{\"status\":[\"exited\"]}").and_return([weave_exec_a])
        expect(weave_exec_a).to receive(:id).and_return("1aed")
        expect(weave_exec_a).to receive(:info).and_return({'Status' => "Exited (0) 5 minutes ago"})
        expect(weave_exec_a).to receive(:remove)

        subject.cleanup_containers
      end

      it 'removes containers exited minutes ago' do
        expect(Docker::Container).to receive(:all).with(all: true, filters: "{\"status\":[\"exited\"]}").and_return([weave_exec_a])
        expect(weave_exec_a).to receive(:id).and_return("2bfe")
        expect(weave_exec_a).to receive(:info).and_return({'Status' => 'Exited (0) 20 minutes ago'})
        expect(weave_exec_a).to receive(:remove)

        subject.cleanup_containers
      end

      it 'removes containers exited hours ago' do
        expect(Docker::Container).to receive(:all).with(all: true, filters: "{\"status\":[\"exited\"]}").and_return([weave_exec_a])
        expect(weave_exec_a).to receive(:id).and_return("fed0")
        expect(weave_exec_a).to receive(:info).and_return({'Status' => 'Exited (0) 2 hours ago'})
        expect(weave_exec_a).to receive(:remove)

        subject.cleanup_containers
      end

      it 'removes containers exited days ago' do
        expect(Docker::Container).to receive(:all).with(all: true, filters: "{\"status\":[\"exited\"]}").and_return([weave_exec_a])
        expect(weave_exec_a).to receive(:id).and_return("ca5b")
        expect(weave_exec_a).to receive(:info).and_return({'Status' => 'Exited (0) 3 days ago'})
        expect(weave_exec_a).to receive(:remove)

        subject.cleanup_containers
      end
    end

    describe '#minutes_ago' do
      it 'converts minutes to minutes' do
        expect(subject.minutes_ago("Exited (0) 4 minutes ago")).to eq(4)
      end

      it 'converts hours to minutes' do
        expect(subject.minutes_ago("Exited (0) 3 hours ago")).to eq(180)
      end

      it 'converts days to minutes' do
        expect(subject.minutes_ago("Exited (0) 2 days ago")).to eq(2880)
      end

      it 'handles unrecognized input' do
        expect(subject.minutes_ago("Exited (0) 1 second ago")).to eq(0)
        expect(subject.minutes_ago("Exited (0) 2 seconds ago")).to eq(0)
        expect(subject.minutes_ago("Exited (0) 7 weeks ago")).to eq(0)
        expect(subject.minutes_ago("Exited (0) 1 month ago")).to eq(0)
        expect(subject.minutes_ago("Exited (0) 3 months ago")).to eq(0)
        expect(subject.minutes_ago("Exited (0) 1 year ago")).to eq(0)
        expect(subject.minutes_ago("Exited (0) 5 years ago")).to eq(0)
      end
    end
end