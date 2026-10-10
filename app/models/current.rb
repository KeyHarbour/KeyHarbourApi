class Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :user, to: :session, allow_nil: true

  def account
    user.account
  end

  def organization_ids
    organizations.pluck(:id)
  end

  def organizations
    return account.organizations if %w[Admin Owner].include?(user.account_user.role.name)

    query_account = user.account_organizations.pluck(:id) + user.project_organizations.pluck(:id) + user.workspace_organizations.pluck(:id)
    account.organizations.where(id: query_account)
  end

  def applications
    account.applications if account
  end

  def app_instances
    account.app_instances if account
  end

  def providers
    account.providers if account
  end

  def add_ons
    account.add_ons if account
  end

  def quotes
    account.quotes if account
  end

  # def team_members
  #   account.team_members if account
  # end

  def project_ids
    projects.pluck(:id)
  end

  def projects
    return account.projects if %w[Admin Owner].include?(user.account_user.role.name)

    query_account = user.account_projects.pluck(:id) + user.organization_projects.pluck(:id) + user.workspace_projects.pluck(:id)
    account.projects.where(id: query_account)
  end

  def workspace_ids
    workspaces.pluck(:id)
  end

  def workspaces
    return account.workspaces if %w[Admin Owner].include?(user&.account_user&.role&.name)

    query_account = user.account_workspaces.pluck(:id) + user.organization_workspaces.pluck(:id) + user.project_workspaces.pluck(:id)
    account.workspaces.where(id: query_account)
  end

  def users
    account.users if account
  end

  def teams
    account.teams if account
  end

  def role
    user.role if user
  end

  def subscription
    account.subscription if account
  end

  def billing_range(full = nil)
    DateTime.now.at_beginning_of_month..DateTime.now
  end

  def current_credit_usage
    Current.account.usage_monthly_accounts.where(month: DateTime.now.at_beginning_of_month..DateTime.now.at_end_of_month).sum(:credits)
  end

  def current_credit_balance
    Current.account.subscription_credits.where(month: DateTime.now.at_beginning_of_month..DateTime.now.at_end_of_month).sum(:credit_balance)
  end
end
