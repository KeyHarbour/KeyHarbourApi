RSpec.shared_context 'organization_token' do
  let(:organization) { create(:organization) }
  let(:token_organization) {create(:token_organization, scopable: organization)}
  let(:Authorization) { "Bearer #{token_organization.generate_token_for(:statefile)}" }
end