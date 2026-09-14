FactoryBot.define do
  factory :account do
    name { Faker::Company.unique.name }
    address1 { "MyString" }
    address2 { "MyString" }
    zip { "MyString" }
    country_code { "MyString" }
    province_code { "MyString" }
    billing_contact { Faker::Internet.email }
  end
end
