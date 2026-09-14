RSpec.shared_context 'workspace_token' do
  let(:token) {create(:token, :for_workspace)}
  let(:workspace) { token.scopable }
  let(:Authorization) { "Bearer #{token.generate_token_for(:statefile)}" }

end