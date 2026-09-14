FactoryBot.define do
  factory :account_user do
    association :user
    association :account
    association :role
  end
end
