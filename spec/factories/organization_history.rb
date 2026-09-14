FactoryBot.define do
  factory :organization_history do
    organization { nil }
    day { "2026-05-10" }
    queries { 1 }
    employees { 1 }
  end
end
