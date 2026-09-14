require 'swagger_helper'

RSpec.describe 'api/v2/statefile', type: :request, openapi_spec: 'v2/openapi.yaml' do
  include_context 'project_token'
  let(:workspace) {create(:workspace, project: project)}
  let(:environment_obj) { create(:environment, organization: project.organization) }
  let(:project_uuid) { project.uuid } 
  let(:workspace_uuid) { workspace.uuid }

  before(:each) do
    create(:statefile, workspace: workspace)
  end
   
  path '/workspaces/{workspace_uuid}/statefiles' do
    get('Get all statefiles') do
      tags 'Statefiles'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'workspace_uuid', in: :path, type: :string
      parameter name: 'environment', in: :query, type: :string
      let(:environment) { environment_obj.name } 

      response '200', 'Project found' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              content: { type: :string },
              uuid: { type: :string },
              published_at: { type: :string, format: :date_time }
            },
            required: %w[content uuid published_at]
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

    delete('delete all statefiles') do
      tags 'Statefiles'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'workspace_uuid', in: :path, type: :string

      response '204', 'no content' do
        run_test!
      end

      response '404', 'Not found' do
        let(:workspace_uuid) { "NOT-EXIST" }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end  

    post('Push new statefile') do
      tags 'Statefiles'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'workspace_uuid', in: :path, type: :string
      parameter name: 'statefile', in: :body, schema: {
        type: :object,
        properties: {
          content: { type: :string }
        },
        required: [ 'content' ]
      }
      let(:statefile) { { content: workspace.statefiles.first.content } }
      let(:environment) { environment_obj.name } 

      response '201', 'Statefile created' do
        schema '$ref' => '#/components/schemas/Created'
        run_test!
      end

      # response '400', 'Bad Request' do 
      #   let(:statefile) { nil }
      #   run_test!
      # end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end 
  end

  path '/workspaces/{workspace_uuid}/statefiles/last' do    
    get('Get last statefile') do
      tags 'Statefiles'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'workspace_uuid', in: :path, type: :string
      let(:environment) { environment_obj.name } 
      let(:statefile2) { create(:statefile, workspace: workspace, environment: environment) }

      response '200', 'Project found' do
        schema type: :object,
          properties: {
            content: { type: :string },
            published_at: { type: :string, format: :"date-time" }
          },
          required: [ 'content', 'published_at' ]

        run_test!
      end

      response '404', 'Not found' do
        before do
          workspace.statefiles.delete_all
        end
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end

  path '/statefiles/{uuid}' do    
    get('Get a specific statefile') do
      tags 'Statefiles'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'uuid', in: :path, type: :string
      let(:uuid) { workspace.statefiles.last.uuid } 

      response '200', 'Project found' do
        schema type: :object,
          properties: {
            content: { type: :string },
            published_at: { type: :string, format: :"date-time" }
          },
          required: [ 'content', 'published_at' ]

        run_test!
      end

      response '404', 'Not found' do
        let(:uuid) { "abcd" } 
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end

    delete('Delete a specific statefile') do
      tags 'Statefiles'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'uuid', in: :path, type: :string
      let(:uuid) { workspace.statefiles.last.uuid } 

      response '204', 'no content' do
        run_test!
      end

      response '404', 'Not found' do
        let(:uuid) { "NOT-EXIST" }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end 
  end
end
