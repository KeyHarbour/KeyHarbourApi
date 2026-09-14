FactoryBot.define do
  factory :inventory_instance_attr, class: 'Inventory::InstanceAttr' do
    instance { nil }
    name { "MyString" }
    value { "MyString" }
  end
end
