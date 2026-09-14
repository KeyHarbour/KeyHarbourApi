RSpec.shared_context 'project_token' do
  let(:token) {create(:token, :for_project)}
  let(:project) { token.scopable }
  let(:organization) { Project.first }
  let(:Authorization) { "Bearer #{token.generate_token_for(:statefile)}" }

end