
describe StackDeploy do
  it { should have_timestamps }
  it { should belong_to(:stack) }
  it { should have_many(:grid_service_deploys) }

  it { should have_index_for(stack_id: 1) }
end
