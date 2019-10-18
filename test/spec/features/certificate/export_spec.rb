describe 'certificate import' do
  include FixturesHelper
  let(:cert_pem) { fixture('certificates/test/cert.pem')}
  let(:key_pem) { fixture('certificates/test/key.pem')}
  let(:key_rsa_pem) { fixture('certificates/test/key_rsa.pem')}
  let(:ca_pem) { fixture('certificates/test/ca.pem')}

  before(:all) do
    with_fixture_dir('certificates/test') do
      run!('krates certificate import --private-key key.pem --chain ca.pem cert.pem')
    end
  end
  after(:all) do
    run("krates certificate rm --force test")
  end

  it 'exports certificate bundle' do
    k = run!("krates certificate export test")

    out = k.out.gsub("\r\n", "\n")

    expect(out).to include(cert_pem)
    expect(out).to include(key_rsa_pem)
    expect(out).to include(ca_pem)
  end

  it 'exports certificate' do
    k = run!("krates certificate export --certificate test")
    expect(k.out.gsub("\r\n", "\n")).to eq(cert_pem)
  end

  it 'exports private key' do
    k = run!("krates certificate export --private-key test")
    expect(k.out.gsub("\r\n", "\n")).to eq(key_rsa_pem) # gets converted
  end

  it 'exports chain' do
    k = run!("krates certificate export --chain test")
    expect(k.out.gsub("\r\n", "\n")).to eq(ca_pem)
  end

  it 'logs audit' do
    run!("krates certificate export --chain test")
    k = run!('krates grid audit-log --lines=10')
    expect(k.out).to match /Certificate.*export/
  end
end
