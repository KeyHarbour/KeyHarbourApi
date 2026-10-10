FactoryBot.define do
  factory :license_quote_instance, class: 'License::QuoteInstance' do
    association :instance, factory: :license_instance
    association :quote, factory: :license_quote
    amount { 250.00 }
  end
end