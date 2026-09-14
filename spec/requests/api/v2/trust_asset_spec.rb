require 'swagger_helper'

RSpec.describe 'Trust Assets', type: :request, openapi_spec: 'v2/openapi.yaml' do
  include_context 'project_token'
  let(:workspace) { create(:workspace, project: project) }
  let(:workspace_uuid) { workspace.uuid }

  before(:each) do
    create(:trust_asset, name: "123", workspace: workspace, environment: token.environment)
  end

  path '/workspaces/{workspace_uuid}/trust_assets' do 
    get('Get all Trust Assets') do 
      tags 'TrustAssets'
      consumes 'application/json'
      produces 'application/json'
      parameter name: 'workspace_uuid', in: :path, type: :string

      response '200', 'Project found' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              name: { type: :string, example: 'my-key-123' },
              issuer: { type: :string, format: :json, example: 'Certigot' },
              expires_at: { type: :string, format: 'date_time' },
              format: { type: :string },
              consumer: { type: :string }
            },
            required: %w[name issuer]
          }
        run_test!
      end

      response '404', 'Not found' do
        let(:workspace_uuid) { "abc" } 
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end
     
    post('Create a new Trust Asset') do
      tags 'TrustAssets'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'workspace_uuid', in: :path, type: :string
      parameter name: :trust_asset, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: 'my-key-123' },
          issuer: { type: :string, format: :json, example: 'Certigot' },
          expires_at: { type: :string, format: 'date_time' },
          format: { type: :integer },
          consumer: { type: :string }
        },
        required: %w[name issuer]
      }

      let(:trust_asset) do 
        {
          name: 'AbC', 
          issuer: 'Certigot',
          expires_at: Time.current.advance(days: 30).iso8601,
          format: 1,
          consumer: 'MyConsumer'
        }
      end
      
      response '201', 'Trust assets created' do
        schema '$ref' => '#/components/schemas/Created'
        run_test!
      end

      response '422', 'Unprocessable Entity' do   
        let(:trust_asset) { {name: 'abc', issuer: 'Certigot'} }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end

  path '/trust_assets/{name}' do
    get('Get a specific trust_asset') do
      tags 'TrustAssets'
      let(:'Accept') { 'application/octet-stream' }
      parameter name: 'name', in: :path, type: :string
      let(:environment) { environment_obj.name } 
      let(:name) { "123" } 

      response '200', 'Donnée lue et détruite' do
        let(:name) { "123" }

        run_test! do
          auth_headers = { 'Authorization' => request.headers['Authorization'] }
          get "/api/v2/trust_assets/#{name}", headers: auth_headers
          expect(response.status).to eq(200)
        end
      end

      response '404', 'Not found' do
        let(:name) { "abc" } 
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end

    patch('Update a specific trust_asset') do
      tags 'TrustAssets'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'name', in: :path, type: :string
      let(:name) { workspace.trust_assets.last.name }

      parameter name: :trust_asset, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: 'my-key-123' },
          issuer: { type: :string, format: :json, example: 'Certigot' },
          expires_at: { type: :string, format: 'date_time' },
          format: { type: :string },
          consumer: { type: :string }
        }
      }
      let(:trust_asset) { {name: 'abc', consumer: 'def'} }

      response '202', 'Workspace updated' do
        schema '$ref' => '#/components/schemas/Updated'
        run_test!
      end

      response '422', 'Unprocessable Entity' do
        let(:trust_asset) { {name: "-&$090" } }
        run_test!
      end

      response '404', 'Not found' do
        let(:name) { workspace.trust_assets.last.name + 'NOTEXISTE' }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end

    delete('Delete a workspace') do
      tags 'TrustAssets'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'name', in: :path, type: :string
      let(:name) { workspace.trust_assets.last.name }

      response '204', 'no content' do
        run_test!
      end

      response '404', 'Not found' do
        let(:name) { "NOT-EXIST" }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end
end