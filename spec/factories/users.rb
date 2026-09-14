FactoryBot.define do
  factory :user do
    # Utilisation d'une séquence pour garantir l'unicité de l'email
    sequence(:email_address) { |n| Faker::Internet.unique.email }
    
    # Requis par has_secure_password
    password { "password123" }
    password_confirmation { "password123" }

    # Rôle par défaut (enum)
    global_role { :default }

    # Trait pour créer un administrateur global
    trait :admin do
      global_role { :admin }
    end

    # Trait pour un compte désactivé
    trait :desactivated do
      global_role { :desactivated }
    end

    # Trait complexe : Crée un utilisateur avec une organisation et un projet
    # Utile pour tester les relations 'through' comme user.projects ou user.workspaces
    trait :with_organization do
      after(:create) do |user|
        org = create(:organization)
        create(:organization_user, user: user, organization: org, role: 'admin')
        
        # Crée un projet pour que user.projects fonctionne
        project = create(:project, organization: org)
        # Crée un workspace pour que user.workspaces fonctionne
        create(:workspace, project: project)
      end
    end

    # Trait pour les équipes
    trait :with_team do
      after(:create) do |user|
        team = create(:team)
        create(:team_user, user: user, team: team)
      end
    end
  end
end
