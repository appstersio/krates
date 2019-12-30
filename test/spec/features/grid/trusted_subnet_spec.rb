describe 'grid trusted-subnet' do
  describe 'list' do
    it 'lists subnets' do
      run! "krates grid trusted-subnet ls"
      # TODO output check
    end
  end

  describe 'add' do
    after(:each) do
      run "krates grid trusted-subnet rm --force 192.168.22.0/24"
    end

    it 'adds a subnet' do
      run! "krates grid trusted-subnet add 192.168.22.0/24"
      # TODO result check
    end
  end

  describe 'remove' do
    it 'removes subnet' do
      run! "krates grid trusted-subnet add 192.168.23.0/24"
      run! "krates grid trusted-subnet rm --force 192.168.23.0/24"
      # TODO result check
    end
  end
end
