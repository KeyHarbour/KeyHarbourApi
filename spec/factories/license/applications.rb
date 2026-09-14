FactoryBot.define do
  factory :license_application, class: 'License::Application' do
    name { Faker::Alphanumeric.alpha(number: 10).downcase }
    short_name { "MyString" }
    owner { "MyString" }
    renewal_date { DateTime.now.advance(days: 30) }
    vendor { Faker::Book.title }
    tier { Faker::Book.title }
    seats { 1 }
    status { 0 }
    uuid { Faker::Internet.uuid }
    association :organization
  end
end
