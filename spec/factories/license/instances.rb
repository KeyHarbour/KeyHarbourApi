FactoryBot.define do
  factory :license_instance, class: 'License::Instance' do
    association :application
    name { "MyString" }
    short_name { "MyString" }
    owner { "MyString" }
    renewal_date { DateTime.now.advance(days: 30) }
    seats { 1 }
    status { 0 }
    uuid { Faker::Internet.uuid }
  end
end
