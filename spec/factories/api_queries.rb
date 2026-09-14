FactoryBot.define do
  factory :api_query do
    association :serviceable, factory: :workspace
    controller { "statefiles" }
    action { "show" }
    token { nil }
    date { Time.current }
    service_name { "KeyValueStore" }

    trait :with_workspace do
      association :serviceable, factory: :workspace
    end
  end
end
