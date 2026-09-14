RSpec.shared_context "member_auth" do
  let(:member_role) { Role.find_or_create_by!(name: "Member") }
  let(:owner_role)  { Role.find_or_create_by!(name: "Owner") }
  let(:inactive_role) { Role.find_or_create_by!(name: "Inactive") }

  let(:account) do
    Account.unscoped.create!(
      name: "Test Account",
      country_code: "CA",
      province_code: "QC",
      billing_contact: "billing@test.com"
    )
  end

  let(:user) { create(:user) }

  let(:account_user) do
    AccountUser.unscoped.create!(user: user, account: account, role: owner_role)
  end

  before do
    account_user # force creation
    session_record = Session.create!(user: user)
    allow(Current).to receive(:session).and_return(session_record)

    allow(user).to receive(:account_admin?).and_return(true) # not sure if it's works....
    allow(Current).to receive(:user).and_return(user)
    allow(Current).to receive(:account).and_return(account)
    allow(Current).to receive(:role).and_return(owner_role)
    # allow(Current).to receive(:role).and_return([owner_role])
    allow(Current).to receive(:organizations).and_return(Organization.unscoped.where(account: account))
    allow(Current).to receive(:projects).and_return(Project.joins(organization: :account).where(accounts: { id: account.id }))
    allow(Current).to receive(:workspaces).and_return(Workspace.joins(project: { organization: :account }).where(accounts: { id: account.id }))
    allow(Current).to receive(:workspace_ids).and_return(Workspace.joins(project: { organization: :account }).where(accounts: { id: account.id }).pluck(:id))
    
    allow(Current).to receive(:teams).and_return(Team.where(account: account))
    allow(Current).to receive(:users).and_return(User.joins(:account_user).where(account_users: { account_id: account.id }))
    allow(Current).to receive(:billing_range).and_return(DateTime.now.advance(months: -1)..DateTime.now)
    allow(Current).to receive(:subscription).and_return(account.subscription)
    allow(Rails.configuration).to receive(:permission_service).and_return(double("ps", get: false))
    cookies.signed[:session_id] = session_record.id
    allow(controller).to receive(:validate_account).and_return(true)
     allow_any_instance_of(ApplicationController).to receive(:enforce_custom_permissions!).and_return(true)
  end
end
