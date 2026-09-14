FactoryBot.define do
  factory :token do
    name { Faker::Book.title }
    association :environment
    last_used_at { Faker::Time.between(from: 2.days.ago, to: Date.today) }
    expiration { Faker::Time.between(from: Date.tomorrow, to: 1.year.from_now)}

    trait :without_environment do
      environment { nil }
      association :scopable, factory: :organization
    end

    trait :for_organization do
      association :scopable, factory: :organization
    end

    trait :for_project do
      association :scopable, factory: :project
    end

    trait :for_workspace do
      association :scopable, factory: :workspace
    end
  end
end