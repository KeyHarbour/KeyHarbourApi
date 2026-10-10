RSpec.shared_context 'project_token' do
  let(:my_project) { create(:project) }
  let(:token_project) {create(:token_project, scopable: my_project)}
  let(:organization) { my_project.organization }
  let(:Authorization) { "Bearer #{token_project.generate_token_for(:statefile)}" }
end