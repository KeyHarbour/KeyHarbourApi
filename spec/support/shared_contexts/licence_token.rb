RSpec.shared_context 'license_token' do
  let(:token) {create(:token, :without_environment)}
  let(:organization) { token.scopable }
  let(:Authorization) { "Bearer #{token.generate_token_for(:statefile)}" }
end