describe Kontena::Workers::ContainerCleanupWorker do
    let(:subject) { described_class.new(false) }
    let(:weave_exec_a) { double() }

    before(:each) { Celluloid.boot }
    after(:each) { Celluloid.shutdown }

    describe '#cleanup_containers' do
      it 'removes exited containers' do
        expect(Docker::Container).to receive(:all).with(all: true, filters: "{\"status\":[\"exited\"]}").and_return([weave_exec_a])
        expect(weave_exec_a).to receive(:id).and_return("1aed")
        expect(weave_exec_a).to receive(:remove)
    
        subject.cleanup_containers
      end
    end
end