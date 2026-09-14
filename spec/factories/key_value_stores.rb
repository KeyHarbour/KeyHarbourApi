FactoryBot.define do
  factory :key_value_store do
    association :workspace
    association :environment
    key { Faker::Internet.uuid }
    expires_at { Faker::Time.forward(days: 2) }
    one_time_only { true }
    private { false }

    # Par défaut, on ne met rien pour forcer l'usage des traits
    value { nil }

    trait :with_value do
      value { Faker::Lorem.sentence }
    end

    trait :with_file do
      value { nil } # On s'assure que value est vide
      after(:build) do |key_value_store|
        # Utilisation de text/plain comme discuté pour éviter les erreurs de parsing
        binary_data = SecureRandom.random_bytes(1024)
        key_value_store.value_file.attach(
          io: StringIO.new(binary_data),
          filename: 'value.txt',
          content_type: 'text/plain' 
        )
      end
    end
  end
end
