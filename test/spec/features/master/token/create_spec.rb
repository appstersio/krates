require 'spec_helper'

describe 'token create' do
  it ' creates a token with description' do
    k = run!('krates master token create --description tokendescriptiontest --id')
    token_id = k.out.strip
    k = run('krates master token list')
    expect(k.out).to match /tokendescriptiontest/
    k = run('krates master token show %s' % token_id)
    expect(k.out).to match /description: tokendescriptiontest/
    run!('krates master token remove --force %s' % token_id)
  end
end
