FactoryBot.define do
  factory :environment do
    association :organization
    name { Faker::Alphanumeric.alpha(number: 10).downcase }
    active { true }
  end
end