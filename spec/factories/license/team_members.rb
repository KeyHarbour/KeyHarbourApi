FactoryBot.define do
  factory :license_team_member, class: 'License::TeamMember' do
    association :organization
    uuid { Faker::Internet.uuid }
    manager { nil }
    
    trait :with_manager do
      association :manager, factory: :license_team_member
    end    
  end
end
