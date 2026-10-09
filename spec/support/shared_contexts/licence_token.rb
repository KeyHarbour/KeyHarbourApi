RSpec.shared_context 'license_token' do
  let(:account) { create(:account)}
  let(:token_account) {create(:token_account, scopable: account)}
  let(:Authorization) { "Bearer #{token_account.generate_token_for(:statefile)}" }
end