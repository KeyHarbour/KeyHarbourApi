require 'swagger_helper'

RSpec.describe 'keyvalue', type: :request, openapi_spec: 'v2/openapi.yaml' do
  include_context 'project_token'
  let(:workspace) { create(:workspace, project: project) }
  let(:workspace_uuid) { workspace.uuid }

  before(:each) do
    create(:key_value_store, :with_value, key: "123", workspace: workspace, environment: token.environment)
    create(:key_value_store, :with_file, key: "456", one_time_only: false, workspace: workspace, environment: token.environment)
  end

  path '/workspaces/{workspace_uuid}/keyvalues' do 
    # get('Get all Keyvalue') do 
    #   tags 'Key/Values'
    #   consumes 'application/json'
    #   produces 'application/json'
    #   parameter name: 'workspace_uuid', in: :path, type: :string

    #   response '200', 'Project found' do
    #     schema type: :array,
    #       items: {
    #         type: :object,
    #         properties: {
    #           key: { type: :string },
    #           expires_at: { type: :string, format: :date_time },
    #           private: { type: :boolean },
    #           one_time_only: { type: :boolean }
    #         },
    #         required: %w[key value]
    #       }
    #     run_test!
    #   end

    #   response '404', 'Not found' do
    #     let(:workspace_uuid) { "abc" } 
    #     run_test!
    #   end

    #   response '401', 'Unauthorized' do
    #     let(:Authorization) { nil }
    #     run_test!
    #   end
    # end
     
    post('Create a new Keyvalue') do
      tags 'Key/Values'
      produces 'application/json'
      consumes 'multipart/form-data'
      parameter name: 'workspace_uuid', in: :path, type: :string

      parameter name: :key_value_store, in: :formData, schema: {
        type: :object,
        properties: {
          key: { type: :string, example: 'my-key-123' },
          value: { type: :string, format: :json, example: '{"test": true}' },
          value_file: { type: :string, format: :binary },
          expires_at: { type: :string, format: :date_time },
          private: { type: :boolean },
          one_time_only: { type: :boolean }
        },
        required: %w[key],
        oneOf: [
          { required: %w[value] },
          { required: %w[value_file] }
        ]
      }

      let(:key_value_store) do 
        {
          key: 'abc', 
          value: Rack::Test::UploadedFile.new(StringIO.new('def'), 'text/plain', original_filename: 'test.txt')
        }
      end
      
      response '201', 'Project created' do
        schema '$ref' => '#/components/schemas/Created'
        run_test!
      end
      
      response '201', 'Project created' do
        let(:key_value_store) do 
          {
            key: 'AbC', 
            value: Rack::Test::UploadedFile.new(StringIO.new('def'), 'text/plain', original_filename: 'test.txt')
          }
        end
        schema '$ref' => '#/components/schemas/Created'
        run_test!
      end

      # response '400', 'Bad Request' do
      #   let(:key_value_store) { nil }
      #   run_test!
      # end

      response '422', 'Unprocessable Entity' do   
        let(:key_value_store) { {key: 'abc'} }
        run_test!
      end

      response '422', 'Unprocessable Entity' do   
        let(:key_value_store) { {key: 'a*3bc', value: Rack::Test::UploadedFile.new(StringIO.new('def'), 'text/plain', original_filename: 'test.txt')} }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end

  path '/keyvalues/{key}' do
    get('Get a specific keyvalue') do
      tags 'Key/Values'
      let(:'Accept') { 'application/octet-stream' }
      parameter name: 'key', in: :path, type: :string
      let(:environment) { environment_obj.name } 
      let(:key) { "123" } 

      response '200', 'Donnée lue et détruite' do
        let(:key) { "456" }

        run_test! do
          auth_headers = { 'Authorization' => request.headers['Authorization'] }
          get "/api/v2/keyvalues/#{key}", headers: auth_headers
          expect(response.status).to eq(200)
        end
      end

      response '200', 'Donnée lue et détruite' do
        # schema type: :string, format: :binary

        run_test! do
          auth_headers = { 'Authorization' => request.headers['Authorization'] }
          get "/api/v2/keyvalues/#{key}", headers: auth_headers
          expect(response.status).to eq(404)
        end
      end

      response '404', 'Not found' do
        let(:key) { "abc" } 
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end

    patch('Update a specific key_value_store') do
      tags 'Key/Values'
      produces 'application/json'
      consumes 'multipart/form-data'
      parameter name: 'key', in: :path, type: :string
      let(:key) { workspace.key_value_stores.last.key }

      parameter name: :key_value_store, in: :formData, schema: {
        type: :object,
        properties: {
          key: { type: :string },
          value: { type: :string },
          value_file: { type: :string, format: :binary },
          expires_at: { type: :string, format: :date_time },
          private: { type: :boolean },
          one_time_only: { type: :boolean }
        },
        required: %w[key],
        oneOf: [
          { required: %w[value] },
          { required: %w[value_file] }
        ]
      }
      let(:key_value_store) { {key: 'abc', value_file: Rack::Test::UploadedFile.new(StringIO.new('def'), 'text/plain', original_filename: 'test.txt')} }

      response '202', 'Workspace updated' do
        schema '$ref' => '#/components/schemas/Updated'
        run_test!
      end

      # response '400', 'Bad Request' do
      #   let(:key_value_store) { nil }
      #   run_test!
      # end

      response '422', 'Unprocessable Entity' do
        let(:key_value_store) { {key: "-&$090" } }
        run_test!
      end

      response '404', 'Not found' do
        let(:key) { workspace.key_value_stores.last.key + 'NOTEXISTE' }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end

    delete('Delete a workspace') do
      tags 'Key/Values'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'key', in: :path, type: :string
      let(:key) { workspace.key_value_stores.last.key }

      response '204', 'no content' do
        run_test!
      end

      response '404', 'Not found' do
        let(:key) { "NOT-EXIST" }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end
end