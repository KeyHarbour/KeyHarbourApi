FactoryBot.define do
  factory :inventory_model_category_attr, class: 'Inventory::ModelCategoryAttr' do
    model_category { nil }
    name { "MyString" }
    attr_name { "MyString" }
    active { false }
  end
end
