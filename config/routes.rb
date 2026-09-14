Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  namespace :statefiles do
    namespace :v1 do
      get ":workspace_uuid/:environment", to: "statefiles#get"
      post ":workspace_uuid/:environment", to: "statefiles#update"
      put ":workspace_uuid/:environment", to: "statefiles#lock"
      delete ":workspace_uuid/:environment", to: "statefiles#unlock"
    end
  end

  namespace :api do
    namespace :v2 do
      get 'auth', to: "application#auth"
      namespace :license do
        get 'auth', to: "application#auth"
        resources :team_members, param: :uuid
        resources :applications, shallow: true, param: :uuid do
          resources :instances, param: :uuid do
            resources :licensees, param: :uuid
          end
        end
      end
      resources :organizations, shallow: true, param: :uuid do
        resources :projects, param: :uuid do
          resources :workspaces, param: :uuid do
            resources :key_value_stores, path: :keyvalues, param: :key, constraints: { key: /[^\/]+/ }
            resources :trust_assets, path: :trust_assets, param: :name
            resources :statefiles, param: :uuid do
              collection do
                delete :delete_all, path: ''
                get :last
              end
            end
          end
        end
      end
    end
  end
end
