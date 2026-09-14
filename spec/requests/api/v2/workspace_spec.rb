require 'swagger_helper'
require 'rails_helper'

RSpec.describe 'api/v1/workspace with organization token', type: :request, openapi_spec: 'v2/openapi.yaml' do
  include_context 'organization_token'
  let(:project) { create(:project, organization: organization) }
  let(:workspace) { create(:workspace, project: project) }
  let(:project_uuid) { project.uuid } 
  let(:existing_workspace) { create(:workspace, project: project) }
   
  path '/projects/{project_uuid}/workspaces' do 
    get('Get all workspaces') do 
      tags 'Workspaces'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'project_uuid', in: :path, type: :string
      let(:project_uuid) { project.uuid } 

      response '200', 'Project found' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              name: { type: :string },
              uuid: { type: :string }
            }
          }
        run_test!
      end

      response '404', 'Not found' do
        let(:project_uuid) { "abc" }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end

    post('Create a new workspace') do
      tags 'Workspaces'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'project_uuid', in: :path, type: :string
      parameter name: :workspace, in: :body, schema: {
        type: :object,
        properties: {
          workspace: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string }
            },
            required: [ 'name', 'description' ]
          }
        },
        required: [ 'workspace' ]
      }
      response '201', 'Workspace created' do
        let(:project_uuid) { project.uuid }
        let(:workspace) { {name: "New Workspace", description: "A new workspace for testing"} }
        schema '$ref' => '#/components/schemas/Created'
        run_test!
      end

      response '400', 'Bad Request' do
        let(:workspace) { "abc" }
        run_test!
      end

      response '422', 'Unprocessable Entity' do
        let(:workspace) { {description: "abc" } }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end

  path '/workspaces/{uuid}' do
    get('Get a specific workspace') do
      tags 'Workspaces'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'uuid', in: :path, type: :string
      let(:uuid) { workspace.uuid }

      response '200', 'Project found' do
        schema type: :object,
          properties: {
            name: { type: :string },
            description: { type: :string }
          },
          required: [ 'name', 'description' ]

        run_test!
      end

      response '404', 'Not found' do
        let(:uuid) { "abc" }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end

    patch('Update a specific workspace') do
      tags 'Workspaces'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'uuid', in: :path, type: :string
      parameter name: 'workspace', in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          description: { type: :string }
        },
        required: [ 'name', 'description' ]
      }


      response '202', 'Workspace updated' do
        let(:uuid) { workspace.uuid }
        schema '$ref' => '#/components/schemas/Updated'
        run_test!
      end

      response '400', 'Bad Request' do
        let(:uuid) { existing_workspace.uuid }
        let(:workspace) { "abc" }
        run_test!
      end

      response '422', 'Unprocessable Entity' do
        let(:uuid) { existing_workspace.uuid }
        let(:workspace) { {name: "" } }
        run_test!
      end

      response '404', 'Not found' do
        let(:uuid) { "NOT-EXIST" }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:uuid) { workspace.uuid }
        let(:Authorization) { nil }
        run_test!
      end
    end

    delete('Delete a workspace') do
      tags 'Workspaces'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'uuid', in: :path, type: :string

      response '204', 'no content' do
        let(:uuid) { existing_workspace.uuid }
        # schema '$ref' => '#/components/schemas/Delete'
        run_test! do |response|
          expect(response.body).to be_blank
          expect(response.status).to eq(204)
        end
      end

      response '404', 'Not found' do
        let(:uuid) { "NOT-EXIST" }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:uuid) { existing_workspace.uuid }
        let(:Authorization) { nil }
        run_test!
      end
    end
  end
end
#
#
# RSpec.describe 'api/v2/workspace with workspace token', type: :request, openapi_spec: 'v2/openapi.yaml' do
#   include_context 'workspace_token'
#   let(:project) { workspace.project }
#   let(:organization) { project.organization }
#   let(:project_uuid) { project.uuid }
#
#   path '/projects/{project_uuid}/workspaces' do
#     get('Get all workspaces') do
#       tags 'Workspaces'
#       produces 'application/json'
#       consumes 'application/json'
#       parameter name: 'project_uuid', in: :path, type: :string
#       let(:project_uuid) { project.uuid }
#
#       response '401', 'Unauthorized' do
#         run_test!
#       end
#
#       response '401', 'Unauthorized' do
#         let(:Authorization) { nil }
#         run_test!
#       end
#     end
#   end
#
#   path '/workspaces/{uuid}' do
#     get('Get a specific workspace') do
#       tags 'Workspaces'
#       produces 'application/json'
#       consumes 'application/json'
#       parameter name: 'uuid', in: :path, type: :string
#       let(:uuid) { workspace.uuid }
#
#       response '200', 'Project found' do
#         schema type: :object,
#           properties: {
#             name: { type: :string },
#             description: { type: :string }
#           },
#           required: [ 'name', 'description' ]
#
#         run_test!
#       end
#
#       response '404', 'Not found' do
#         let(:uuid) { "abc" }
#         run_test!
#       end
#
#       response '401', 'Unauthorized' do
#         let(:Authorization) { nil }
#         run_test!
#       end
#     end
#
#     delete('Delete a workspace') do
#       tags 'Workspaces'
#       produces 'application/json'
#       consumes 'application/json'
#       parameter name: 'uuid', in: :path, type: :string
#       let(:uuid) { workspace.uuid }
#
#       response '204', 'Unauthorized' do
#         # schema '$ref' => '#/components/schemas/Delete'
#         run_test!
#       end
#
#       response '404', 'Not found' do
#         let(:uuid) { "NOT-EXIST" }
#         run_test!
#       end
#
#       response '401', 'Unauthorized' do
#         let(:Authorization) { nil }
#         run_test!
#       end
#     end
#   end
# end
#
# RSpec.describe 'api/v2/workspace with project token', type: :request, openapi_spec: 'v2/openapi.yaml' do
#   include_context 'project_token'
#   let(:workspace) { create(:workspace, project: project) }
#   let(:project_uuid) { project.uuid }
#
#   path '/projects/{project_uuid}/workspaces' do
#     get('Get all workspaces') do
#       tags 'Workspaces'
#       produces 'application/json'
#       consumes 'application/json'
#       parameter name: 'project_uuid', in: :path, type: :string
#       let(:project_uuid) { project.uuid }
#
#       response '200', 'Project found' do
#         schema type: :array,
#           items: {
#             type: :object,
#             properties: {
#               name: { type: :string },
#               uuid: { type: :string }
#             }
#           }
#         run_test!
#       end
#
#       response '404', 'Not found' do
#         let(:project_uuid) { "abc" }
#         run_test!
#       end
#
#       response '401', 'Unauthorized' do
#         let(:Authorization) { nil }
#         run_test!
#       end
#     end
#
#     post('Create a new workspace') do
#       tags 'Workspaces'
#       produces 'application/json'
#       consumes 'application/json'
#       parameter name: 'project_uuid', in: :path, type: :string
#       parameter name: :workspace, in: :body, schema: {
#         type: :object,
#         properties: {
#           workspace: {
#             type: :object,
#             properties: {
#               name: { type: :string },
#               description: { type: :string }
#             },
#             required: [ 'name', 'description' ]
#           }
#         },
#         required: [ 'workspace' ]
#       }
#       response '201', 'Project created' do
#         let(:project_uuid) { project.uuid }
#         let(:workspace) { {name: "New Workspace", description: "A new workspace for testing"} }
#         schema '$ref' => '#/components/schemas/Created'
#         run_test!
#       end
#
#       response '400', 'Bad Request' do
#         let(:workspace) { "abc" }
#         run_test!
#       end
#
#       response '422', 'Unprocessable Entity' do
#         let(:workspace) { {description: "abc" } }
#         run_test!
#       end
#
#       response '401', 'Unauthorized' do
#         let(:Authorization) { nil }
#         run_test!
#       end
#     end
#   end
#
#   path '/workspaces/{uuid}' do
#     get('Get a specific workspace') do
#       tags 'Workspaces'
#       produces 'application/json'
#       consumes 'application/json'
#       parameter name: 'uuid', in: :path, type: :string
#       let(:uuid) { workspace.uuid }
#
#       response '200', 'Project found' do
#         schema type: :object,
#           properties: {
#             name: { type: :string },
#             description: { type: :string }
#           },
#           required: [ 'name', 'description' ]
#
#         run_test!
#       end
#
#       response '404', 'Not found' do
#         let(:uuid) { "abc" }
#         run_test!
#       end
#
#       response '401', 'Unauthorized' do
#         let(:Authorization) { nil }
#         run_test!
#       end
#     end
#
#     patch('Update a specific workspace') do
#       tags 'Workspaces'
#       produces 'application/json'
#       consumes 'application/json'
#       parameter name: 'uuid', in: :path, type: :string
#       parameter name: 'workspace', in: :body, schema: {
#         type: :object,
#         properties: {
#           name: { type: :string },
#           description: { type: :string }
#         },
#         required: [ 'name', 'description' ]
#       }
#       let(:workspace_upd) { create(:workspace, project: project) }
#       let(:uuid) { workspace_upd.uuid }
#
#       response '202', 'Workspace updated' do
#         let(:uuid) { workspace.uuid }
#         schema '$ref' => '#/components/schemas/Updated'
#         run_test!
#       end
#
#       response '400', 'Bad Request' do
#         let(:workspace) { "abc" }
#         run_test!
#       end
#
#       response '422', 'Unprocessable Entity' do
#         let(:workspace) { {name: "" } }
#         run_test!
#       end
#
#       response '404', 'Not found' do
#         let(:uuid) { "NOT-EXIST" }
#         run_test!
#       end
#
#       response '401', 'Unauthorized' do
#         let(:Authorization) { nil }
#         run_test!
#       end
#     end
#
#     delete('Delete a workspace') do
#       tags 'Workspaces'
#       produces 'application/json'
#       consumes 'application/json'
#       parameter name: 'uuid', in: :path, type: :string
#       let(:uuid) { workspace.uuid }
#
#       response '204', 'no content' do
#         # schema '$ref' => '#/components/schemas/Delete'
#         run_test! do |response|
#           expect(response.body).to be_blank
#           expect(response.status).to eq(204)
#         end
#       end
#
#       response '404', 'Not found' do
#         let(:uuid) { "NOT-EXIST" }
#         run_test!
#       end
#
#       response '401', 'Unauthorized' do
#         let(:Authorization) { nil }
#         run_test!
#       end
#     end
#   end
# end