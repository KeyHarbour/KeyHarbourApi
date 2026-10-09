FactoryBot.define do
  factory :license_quote_add_on, class: 'License::QuoteAddOn' do
    association :add_on, factory: :license_add_on
    association :quote, factory: :license_quote
    amount { 250.00 }
  end
end