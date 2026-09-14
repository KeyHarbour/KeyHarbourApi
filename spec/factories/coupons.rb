FactoryBot.define do
  factory :coupon do
    name { "MyString" }
    valid_at { "2026-06-08" }
    valid_until { "2026-06-08" }
    uuid { "MyString" }
    amount_off { "9.99" }
    percent_off { "9.99" }
    duration_limited { true }
    duration_in_month { 1 }
    redeem_limit { 1 }
  end
end
