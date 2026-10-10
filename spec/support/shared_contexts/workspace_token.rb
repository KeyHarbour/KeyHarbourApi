RSpec.shared_context 'workspace_token' do
  let(:workspace) { create(:workspace) }
  let(:token_workspace) {create(:token_workspace, scopable: workspace)}
  let(:Authorization) { "Bearer #{token_workspace.generate_token_for(:statefile)}" }
end