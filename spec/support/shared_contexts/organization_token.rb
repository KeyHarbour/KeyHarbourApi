RSpec.shared_context 'organization_token' do
  let(:token) {create(:token, :for_organization)}
  let(:organization) { token.scopable }
  let(:Authorization) { "Bearer #{token.generate_token_for(:statefile)}" }

end