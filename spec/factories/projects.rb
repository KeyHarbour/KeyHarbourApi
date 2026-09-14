FactoryBot.define do
  factory :project do
    association :organization
    name { Faker::Book.title }
    uuid { Faker::Internet.uuid }
  end
end
