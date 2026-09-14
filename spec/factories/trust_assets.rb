FactoryBot.define do
  factory :trust_asset do
    association :workspace
    association :environment
    name { Faker::Book.title }
    expires_at { Time.current.advance(days: 30) }
    issuer { "MyString" }
    format { 1 }
    consumer { "MyString" }
    description { "MyText" }
    reminder_days { 1 }
  end
end
