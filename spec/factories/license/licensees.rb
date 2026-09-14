FactoryBot.define do
  factory :license_licensee, class: 'License::Licensee' do
    association :instance
    uuid { Faker::Internet.uuid }
    status { 0 }
  end
end
