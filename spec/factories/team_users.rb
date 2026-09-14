FactoryBot.define do
  factory :team_user do
    association :team
    association :user
    role { 1 }

    trait :admin do
      role { 0 }
    end
  end
end
