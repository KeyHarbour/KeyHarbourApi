FactoryBot.define do
  factory :notification do
    association :recipient, factory: :user
    title { "Test notification" }
    message { "Test message" }
    read_at { nil }
  end
end
