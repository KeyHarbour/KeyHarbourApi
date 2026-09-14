FactoryBot.define do
  factory :action_log do
    user_id { 1 }
    organization_id { 1 }
    controller { "workspaces" }
    action { "show" }
    action_id { 42 }
    method_type { "GET" }
  end
end
