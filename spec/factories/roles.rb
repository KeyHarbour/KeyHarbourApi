FactoryBot.define do
  factory :role do
    name { "Viewer" }

    trait :owner  do name { "Owner" }  end
    trait :admin  do name { "Admin" }  end
    trait :editor do name { "Editor" } end
    trait :viewer do name { "Viewer" } end
  end
end
