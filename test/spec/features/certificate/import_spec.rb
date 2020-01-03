describe 'certificate import' do
  after(:each) do
    run("krates certificate rm --force test")
  end

  it 'imports certificates from file' do
    with_fixture_dir('certificates/test') do
      run!('krates certificate import --private-key key.pem --chain ca.pem cert.pem')
    end

    k = run!("krates certificate list -q")
    expect(k.out.lines.map{|l| l.strip}).to include 'test'

    k = run!("krates certificate show test")
    expect(k.out.lines.map{|l| l.strip}).to include 'subject: test'
  end
end
