FactoryBot.define do
  factory :team do
    association :account
    name { Faker::Internet.username }
    uuid { Faker::Internet.uuid }
    description { "MyString" }
    source { 1 }
  end
end
