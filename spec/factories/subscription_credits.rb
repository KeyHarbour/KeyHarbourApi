FactoryBot.define do
  factory :subscription_credit do
    association :subscription
    month { Date.today.beginning_of_month }
    credits { 10 }
    credit_balance { 10 }
    event { :initial }
    order { 1 }
  end
end
