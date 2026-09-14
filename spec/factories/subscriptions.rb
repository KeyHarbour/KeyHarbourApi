FactoryBot.define do
  factory :subscription do
    association :account
    stripe_customer_id { "MyString" }
    plan_id { "free" }
    current_period_end { 1.month.from_now }
    current_period_start { Time.now }
  end
end
