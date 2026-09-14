FactoryBot.define do
  factory :email_change do
    user { nil }
    from { "MyString" }
    to { "MyString" }
    confirmed_at { "2025-11-01 11:22:07" }
  end
end
