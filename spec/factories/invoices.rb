FactoryBot.define do
  factory :invoice do
    association :subscription
    amount { 9.99 }
    period_end { Date.today }
    period_start { 1.month.ago.to_date }
    sequence(:stripe_invoice_id) { |n| "in_test_#{n}" }
  end
end
