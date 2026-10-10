FactoryBot.define do
  factory :license_provider, class: 'License::Provider' do
    association :account
    name { "MyString" }
    uuid { Faker::Internet.uuid }
  end
end
