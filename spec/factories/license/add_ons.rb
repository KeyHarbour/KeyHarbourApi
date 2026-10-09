FactoryBot.define do
  factory :license_add_on, class: 'License::AddOn' do
    association :instance
    name { "MyString" }
    uuid { Faker::Internet.uuid }
    description { "MyString" }
    active { true }
    unit_cost { 0.00 }
  end
end
