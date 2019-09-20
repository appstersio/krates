require 'kontena/plugin_manager'

describe Kontena::PluginManager::Common do
  let(:subject) { described_class }

  context '#prefix' do
    it 'converts vagrant to krates-plugin-vagrant' do
      expect(subject.prefix('vagrant')).to eq 'krates-plugin-vagrant'
    end

    it 'returns the same if the string is already prefixed' do
      expect(subject.prefix('krates-plugin-vagrant')).to eq 'krates-plugin-vagrant'
    end
  end

  context '#installed' do
    before(:each) do
      allow(subject).to receive(:plugins).and_return([double(name: 'krates-plugin-foo'), double(name: 'krates-plugin-bar')])
    end

    it 'returns an installed spec by name' do
      expect(subject.installed('bar').name).to eq 'krates-plugin-bar'
    end

    it 'returns nothing if not found' do
      expect(subject.installed('baz')).to be_nil
    end

    context '#installed?' do
      it 'returns true if the plugin is installed' do
        expect(subject.installed?('bar')).to be_truthy
      end

      it 'returns false if the plugin is not installed' do
        expect(subject.installed?('baz')).to be_falsey
      end
    end
  end
end
