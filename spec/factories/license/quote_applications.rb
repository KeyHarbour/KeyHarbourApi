FactoryBot.define do
  factory :license_quote_application, class: 'License::QuoteApplication' do
    association :application, factory: :license_application
    association :quote, factory: :license_quote
    amount { 1500.50 }
  end
end