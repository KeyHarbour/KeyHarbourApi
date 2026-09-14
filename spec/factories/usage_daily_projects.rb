FactoryBot.define do
  factory :usage_daily_project do
    association :project
    day { Date.today }
    credits { 1 }
    units { 1 }
    service_name { "KeyValueStore" }
  end
end
