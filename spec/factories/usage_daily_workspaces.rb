FactoryBot.define do
  factory :usage_daily_workspace do
    association :workspace
    day { Date.today }
    credits { 1 }
    units { 1 }
    service_name { "KeyValueStore" }
  end
end
