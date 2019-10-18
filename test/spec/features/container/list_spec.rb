describe 'container list' do
  it 'lists containers' do 
    k = run("krates container list")
    expect(k.out.match(/.*krates-worker.*/)).to be_truthy
  end
end