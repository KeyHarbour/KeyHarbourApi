FactoryBot.define do
  factory :inventory_model_category, class: 'Inventory::ModelCategory' do
    organization { nil }
    name { "MyString" }
    resource_type { "MyString" }
  end
end
