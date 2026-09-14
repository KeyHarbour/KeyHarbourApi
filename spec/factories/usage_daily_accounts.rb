FactoryBot.define do
  factory :usage_daily_account do
    association :account
    day { Date.today }
    credits { 1 }
    units { 1 }
    service_name { "KeyValueStore" }
  end
end
