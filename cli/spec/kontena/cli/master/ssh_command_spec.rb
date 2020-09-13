require 'kontena/cli/master/ssh_command'

describe Kontena::Cli::Master::SshCommand do
  include ClientHelpers

  let(:master_host) { 'master.krates.io' }
  let(:identity_file) { '~/x/y/z/id_rsa' }

  before do
    allow(client).to receive(:get).with('v1/config/server.provider').and_return({})
    allow(subject).to receive(:master_host).and_return(master_host)
    # NOTE: This stub should be factored out into its own context in case of Vagrant spec support
    allow(subject).to receive(:master_is_vagrant?).and_return(false)
  end

  it "uses environment variable to provide identity file to SSH" do
    # Stub
    allow(ENV).to receive(:key?).and_return(true)
    allow(ENV).to receive(:[]).with('KRATES_MASTER_IDENTITY_FILE').and_return(identity_file)
    # Assert
    expect(subject).to receive(:exec).with('ssh', "core@#{master_host}", '-i', identity_file)
    subject.run []
  end
end