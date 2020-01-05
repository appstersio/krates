require 'openssl'
require 'tmpdir'

describe 'krates/lb certificates' do
  let(:tmp_path) { Dir.mktmpdir('kontena-cert-test_') }
  let(:cert_path) { File.join(tmp_path, 'cert.pem') }
  let(:key_path) { File.join(tmp_path, 'key.pem') }

  before(:each) do
    run!("openssl req -x509 -newkey rsa:2048 -keyout #{key_path} -out #{cert_path} -days 1 -nodes -subj /CN=localhost")

    run!("krates certificate import --private-key=#{key_path} #{cert_path}")

    with_fixture_dir('stack/certificates') do
      k = run('krates stack install -v certificate=localhost kontena-lb.yml')
      expect(k.code).to eq(0), k.out
    end

    sleep 5 # XXX: wait for lb service to be ready...
  end

  after(:each) do
    run("krates stack rm --force cert-test")
    run("krates certificate rm --force localhost")
    run("rm -rf #{tmp_path}")
  end

  it 'deploys the certificate to the LB for https' do
    k = run!("curl --cacert #{cert_path} https://localhost")
    expect(k.out).to include 'whoami-1.cert-test.e2e.kontena.local'
  end
end
