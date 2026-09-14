FactoryBot.define do
  factory :team_role do
    association :team
    resource { nil }
    role { 0 }

    trait :with_org do
      association :resource, factory: :organization
    end

    trait :with_prj do
      association :resource, factory: :project
    end

    trait :with_wks do
      association :resource, factory: :workspace
    end
  end
end
