FactoryBot.define do
  factory :statefile_lock do
    association :workspace
    locked_at { Time.current }
  end
end
