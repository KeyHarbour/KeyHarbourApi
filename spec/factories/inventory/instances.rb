FactoryBot.define do
  factory :inventory_instance, class: 'Inventory::Instance' do
    workspace { nil }
    name { "MyString" }
    uuid { "MyString" }
    status { 1 }
  end
end
