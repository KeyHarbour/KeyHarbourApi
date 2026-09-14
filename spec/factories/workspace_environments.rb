FactoryBot.define do
  factory :workspace_environment do
    workspace { nil }
    environment { nil }
    resources { 1 }
    lines { 1 }
    size { 1 }
  end
end
