FactoryBot.define do
  factory :usage_monthly_account do
    association :account
    month { Date.today.beginning_of_month }
    credits { 1 }
  end
end
