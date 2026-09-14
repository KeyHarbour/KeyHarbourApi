FactoryBot.define do
  factory :usage_daily_organization do
    association :organization
    day { Date.today }
    credits { 1 }
    units { 1 }
    service_name { "KeyValueStore" }
  end
end
