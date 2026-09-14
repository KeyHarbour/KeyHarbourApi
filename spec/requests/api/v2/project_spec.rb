require 'swagger_helper'

RSpec.describe 'api/v2/projects', type: :request, openapi_spec: 'v2/openapi.yaml' do
  include_context 'project_token'

  path '/organizations/{organization_uuid}/projects' do 
    get('Get all projects') do 
      tags 'Projects'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'organization_uuid', in: :path, type: :string
      let(:organization_uuid) { organization.uuid } 

      response '401', 'Unauthorized' do
        run_test!
      end
    end
     
    post('Create a new project') do
      tags 'Projects'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'organization_uuid', in: :path, type: :string
      parameter name: :project, in: :body, schema: {
        type: :object,
        properties: {
          project: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              environment_names: {
                type: :array,
                items: { type: :string }
              }
            },
            required: [ 'name', 'environment_names' ]
          }
        },
        required: [ 'project' ]
      }

      response '401', 'Unauthorized' do
        let(:organization_uuid) { organization.uuid }
        let(:project) { {description: "abc" } }
        run_test!
      end
    end
  end

  path '/projects/{uuid}' do
    get('get project detail') do
      tags 'Projects'
      produces 'application/json'
      parameter name: 'uuid', in: :path, type: :string

      let(:uuid) { project.uuid } 

      response '200', 'Project found' do
        schema type: :object,
          properties: {
            name: { type: :string },
            environment_names: {
              type: :array,
              items: { type: :string }
            }
          },
          required: [ 'name', 'environments' ]

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

    patch('update project detail') do
      tags 'Projects'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'uuid', in: :path, type: :string
      parameter name: 'project', in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          environment_names: {
            type: :array,
            items: { type: :string }
          }
        },
        required: [ 'name', 'environment_names' ]
      }

      let(:uuid) { project.uuid } 

      response '202', 'Project updated' do
        schema '$ref' => '#/components/schemas/Updated'
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
  end
end

RSpec.describe 'api/v2/projects', type: :request, openapi_spec: 'v2/openapi.yaml' do
  include_context 'organization_token'
   
  path '/organizations/{organization_uuid}/projects' do 
    get('Get all projects') do 
      tags 'Projects'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'organization_uuid', in: :path, type: :string
      let(:organization_uuid) { organization.uuid } 

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
        let(:organization_uuid) { "abc" } 
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end
     
    post('Create a new project') do
      tags 'Projects'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'organization_uuid', in: :path, type: :string
      parameter name: :project, in: :body, schema: {
        type: :object,
        properties: {
          project: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              environment_names: {
                type: :array,
                items: { type: :string }
              }
            },
            required: [ 'name', 'environment_names' ]
          }
        },
        required: [ 'project' ]
      }
      response '201', 'Projects created' do
        let(:organization_uuid) { organization.uuid }
        let(:project) { {name: "New Workspace", description: "A new project for testing"} }
        schema '$ref' => '#/components/schemas/Created'
        run_test!
      end

      response '400', 'Bad Request' do
        let(:organization_uuid) { organization.uuid }
        let(:project) { "abc" } 
        run_test!
      end

      response '422', 'Unprocessable Entity' do   
        let(:organization_uuid) { organization.uuid }
        let(:project) { {description: "abc" } }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:organization_uuid) { organization.uuid }
        let(:Authorization) { nil }
        let(:project) { {description: "abc" } }
        run_test!
      end
    end
  end

  # path '/projects/{uuid}' do
  #   get('get project detail') do
  #     tags 'Projects'
  #     produces 'application/json'
  #     parameter name: 'uuid', in: :path, type: :string
  #     let(:project) { create(:project, organization: organization) }
  #     let(:uuid) { project.uuid } 

  #     response '200', 'Project found' do
  #       schema type: :object,
  #         properties: {
  #           name: { type: :string },
  #           environment_names: {
  #             type: :array,
  #             items: { type: :string }
  #           }
  #         },
  #         required: [ 'name', 'environments' ]

  #       run_test!
  #     end

  #     response '400', 'Not found' do
  #       let(:uuid) { nil } 
  #       run_test!
  #     end

  #     response '404', 'Not found' do
  #       let(:uuid) { "abc" } 
  #       run_test!
  #     end

  #     response '401', 'Unauthorized' do
  #       let(:Authorization) { nil }
  #       run_test!
  #     end
  #   end

  #   patch('update project detail') do
  #     tags 'Projects'
  #     produces 'application/json'
  #     consumes 'application/json'
  #     parameter name: 'uuid', in: :path, type: :string
  #     parameter name: 'project', in: :body, schema: {
  #       type: :object,
  #       properties: {
  #         name: { type: :string },
  #         environment_names: {
  #           type: :array,
  #           items: { type: :string }
  #         }
  #       },
  #       required: [ 'name', 'environment_names' ]
  #     }

  #     let(:project) { create(:project, organization: organization) }
  #     let(:uuid) { project.uuid } 

  #     response '202', 'Project updated' do
  #       schema '$ref' => '#/components/schemas/Updated'
  #       run_test!
  #     end

  #     response '404', 'Not found' do
  #       let(:uuid) { "abc" } 
  #       run_test!
  #     end

  #     response '401', 'Unauthorized' do
  #       let(:Authorization) { nil }
  #       run_test!
  #     end
  #   end    
  # end
end