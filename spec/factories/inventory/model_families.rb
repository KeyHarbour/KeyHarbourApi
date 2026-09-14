FactoryBot.define do
  factory :inventory_model_family, class: 'Inventory::ModelFamily' do
    organization { nil }
    name { "MyString" }
  end
end
