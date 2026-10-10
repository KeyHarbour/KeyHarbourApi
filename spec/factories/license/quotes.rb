FactoryBot.define do
  factory :license_quote, class: 'License::Quote' do
    association :application, factory: :license_application
    association :provider, factory: :license_provider
    uuid { SecureRandom.uuid }
    available_on { Date.current }
    available_until { 1.month.from_now.to_date }
    approved_at { nil }
    status { :intial }
  end
end
