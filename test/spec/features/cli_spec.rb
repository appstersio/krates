require 'spec_helper'

describe 'cli' do
  it 'can run --help on all subcommands' do
    run('krates complete --subcommand-tree').out.split(/[\r\n]/).reject { |cmd| cmd.empty? || cmd =~ /\[.+?\]/ }.each do |command|
      k = run!(command + ' --help')
      expect(k.out).to match(/Usage:/)
      expect(k.out).to match(/Options:/)
    end
  end

  context 'option parsing' do
    after do
      run 'krates vault rm --force testsecret'
    end

    it 'allows options after parameters' do
      run! 'krates vault write testsecret --silent testvalue'
      k = run! 'krates vault read testsecret --value'
      expect(k.out.strip).to eq 'testvalue'
    end

    it 'breaks option parsing at double dash' do
      run! 'krates vault write testsecret -- --silent'
      k = run! 'krates vault read testsecret --value'
      expect(k.out.strip).to eq '--silent'
    end
  end
end
