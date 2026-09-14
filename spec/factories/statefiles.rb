FactoryBot.define do
  factory :statefile do
    association :workspace
    association :environment
    content { '{ "version": 4, "resources": [] }' }
    published_at { Time.current }
  end
end