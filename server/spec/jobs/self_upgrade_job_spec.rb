# Self-upgrade job test specification
describe SelfUpgradeJob, celluloid: true do
  # Stub the actor, because Celluloid
  let(:actor) { described_class.new(false) }
  # Stub versions
  let(:v0_9_0) { Gem::Version.create('0.9.0') }
  let(:v1_0_0) { Gem::Version.create('1.0.0') }
  let(:v1_1_0) { Gem::Version.create('1.1.0') }
  # Why? You know, because Celluloid
  subject { actor.wrapped_object }

  describe '#poll_upgrade' do
    it 'triggers update to the latest version' do
      # Arrange
      allow(subject).to receive(:current_version) { v1_0_0 }
      allow(subject).to receive(:latest_version) { v1_1_0 }
      # Assert
      expect(subject).to receive(:shutdown)
      # Act
      subject.poll_upgrade
    end

    it 'skips current version' do
      # Arrange
      allow(subject).to receive(:current_version) { v1_0_0 }
      allow(subject).to receive(:latest_version) { v1_0_0 }
      # Assert
      expect(subject).to_not receive(:shutdown)
      # Act
      subject.poll_upgrade
    end

    it 'skips previous version' do
      # Arrange
      allow(subject).to receive(:current_version) { v1_0_0 }
      allow(subject).to receive(:latest_version) { v0_9_0 }
      # Assert
      expect(subject).to_not receive(:shutdown)
      # Act
      subject.poll_upgrade
    end
  end
end