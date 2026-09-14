FactoryBot.define do
  factory :subscription_coupon do
    association :subscription
    association :coupon
    used { Date.today }
  end
end
