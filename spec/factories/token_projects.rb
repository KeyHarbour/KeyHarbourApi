FactoryBot.define do
  factory :token_project, class: 'TokenProject' do
    name { Faker::Book.title }
    association :environment
    last_used_at { Faker::Time.between(from: 2.days.ago, to: Date.today) }
    expiration { Faker::Time.between(from: Date.tomorrow, to: 1.year.from_now)}
    association :scopable, factory: :project
  end
end