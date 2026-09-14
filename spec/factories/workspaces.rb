FactoryBot.define do
  factory :workspace do
    association :project
    name { Faker::Alphanumeric.alpha(number: 10).downcase }
    uuid { Faker::Internet.uuid }
    description { Faker::Lorem.paragraph }
  end
end