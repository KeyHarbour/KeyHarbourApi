FactoryBot.define do
  factory :organization do
    association :account
    name { Faker::Book.title }
    uuid { Faker::Internet.uuid }
    description { Faker::Lorem.paragraph }
  end
end