require 'spec_helper'

# NOTE: At some point registry stopped accepting unauthenticated requests.
# Therefore first step is to mark these tests as :broken,
# and second step is to adjust the code to use Github as the source of predefined & usable stacks.
describe 'stack registry', :broken => true do
  context 'search' do
    it 'shows a list of stacks' do
      k = run! 'krates stack registry search'
      expect(k.out.lines.size > 20).to be_truthy
      expect(k.out).to match /kontena\/ingress-lb/
    end

    it 'shows a list of stacks filtered by name' do
      k = run! 'krates stack registry search kontena/ingress-lb'
      expect(k.out).to match /VERSION/
      expect(k.out).to match /kontena\/ingress-lb/
    end

    it 'shows a list of stacks filtered by description' do
      k = run! 'krates stack registry search balancer'
      expect(k.out).to match /kontena\/ingress-lb/
    end
  end
end
