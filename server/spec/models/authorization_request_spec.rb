
describe AuthorizationRequest do
  it { should have_timestamps }
  it { should have_fields(:state, :redirect_uri, :scope).of_type(String) }
  it { should have_fields(:deleted_at).of_type(BSON::Timestamp) }
  it { should have_fields(:expires_in).of_type(Integer) }

  it { should belong_to(:user) }

  it { should have_index_for(state: 1) }
  it { should have_index_for(created_at: 1).with_options(expire_after_seconds: 3600) }
  it { should have_index_for(deleted_at: 1) }
end
