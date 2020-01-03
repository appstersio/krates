describe 'update grid' do
  it 'validates log opts' do
    k = run "krates grid update --log-opt server=foo e2e"
    expect(k.code).not_to be_zero
    expect(k.out).to match /Need to specify --log-forwarder when using --log-opt/
  end

  it 'updates log shipping' do
    run! "krates grid update --log-forwarder fluentd --log-opt fluentd-address=foo e2e"
    k = run! "krates grid show e2e"
    expect(k.out).to match /fluentd/
  end
end
