require 'swagger_helper'

RSpec.describe 'api/v2/projects', type: :request, openapi_spec: 'api_v2/openapi.yaml' do
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
        let(:project) { { project: { description: "abc" } } }
        run_test!
      end
    end
  end

  path '/projects/{uuid}' do
    get('get project detail') do
      tags 'Projects'
      produces 'application/json'
      parameter name: 'uuid', in: :path, type: :string

      let(:uuid) { my_project.uuid } 

      response '200', 'Project found' do
        schema '$ref' => '#/components/schemas/Project'

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

      let(:uuid) { my_project.uuid } 

      response '202', 'Project updated' do
        schema '$ref' => '#/components/schemas/Updated'
        let(:project) { { project: my_project } }
        run_test!
      end

      response '404', 'Not found' do
        let(:uuid) { "abc" } 
        let(:project) { { project: { description: "abc" } } }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        let(:project) { { project: { description: "abc" } } }
        run_test!
      end
    end    
  end
end

RSpec.describe 'api/v2/projects', type: :request, openapi_spec: 'api_v2/openapi.yaml' do
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
        schema '$ref' => '#/components/schemas/Project'
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['status']).to eq('created')
          expect(json['uuid']).to eq(organization.projects.find_by(name: 'New Workspace').uuid)
        end
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

  path '/projects/{uuid}' do
    get('get project detail') do
      tags 'Projects'
      produces 'application/json'
      parameter name: 'uuid', in: :path, type: :string
      let(:project) { create(:project, organization: organization) }
      let(:uuid) { project.uuid } 

      response '200', 'Project found' do
        schema '$ref' => '#/components/schemas/Project'

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

      let(:project) { create(:project, organization: organization) }
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

# Environments are accepted by name, as documented, and project responses carry
# the project's uuid and environments.
RSpec.describe 'api/v2/projects environments', type: :request do
  include_context 'organization_token'

  let(:headers) { { 'Authorization' => self.Authorization, 'Content-Type' => 'application/json', 'Accept' => 'application/json' } }
  let!(:production) { create(:environment, organization: organization, name: 'production') }
  let!(:staging) { create(:environment, organization: organization, name: 'staging') }

  def create_project(body)
    post "/api/v2/organizations/#{organization.uuid}/projects", params: body.to_json, headers: headers
  end

  def update_project(record, body)
    patch "/api/v2/projects/#{record.uuid}", params: body.to_json, headers: headers
  end

  it 'attaches environments given by name on create, case-insensitively' do
    create_project(project: { name: 'web', environment_names: %w[Production staging] })

    expect(response).to have_http_status(:created)
    created = organization.projects.find_by(name: 'web')
    expect(created.environment_names).to match_array(%w[production staging])
    json = JSON.parse(response.body)
    expect(json).to include('uuid' => created.uuid, 'name' => 'web', 'status' => 'created')
    expect(json['environment_names']).to match_array(%w[production staging])
  end

  it 'rejects an unknown environment name instead of dropping it' do
    expect {
      create_project(project: { name: 'web', environment_names: %w[production prod] })
    }.not_to change(Project, :count)

    expect(response).to have_http_status(:unprocessable_entity)
    json = JSON.parse(response.body)
    expect(json['message']).to include('prod')
    expect(json['available_environments']).to match_array(%w[production staging])
  end

  it 'accepts an unwrapped body with environment names' do
    create_project(name: 'web', environment_names: %w[staging])

    expect(response).to have_http_status(:created)
    expect(organization.projects.find_by(name: 'web').environment_names).to eq(%w[staging])
  end

  it 'replaces the environment list on update' do
    record = create(:project, organization: organization)
    record.environments << production

    update_project(record, project: { environment_names: %w[staging] })

    expect(response).to have_http_status(:accepted)
    expect(record.reload.environment_names).to eq(%w[staging])
  end

  it 'leaves environments alone when they are not sent' do
    record = create(:project, organization: organization)
    record.environments << production

    update_project(record, project: { name: 'renamed' })

    expect(response).to have_http_status(:accepted)
    expect(record.reload).to have_attributes(name: 'renamed', environment_names: %w[production])
  end

  it 'rejects an unknown environment name on update' do
    record = create(:project, organization: organization)
    record.environments << production

    update_project(record, project: { environment_names: %w[nope] })

    expect(response).to have_http_status(:unprocessable_entity)
    expect(record.reload.environment_names).to eq(%w[production])
  end

  it 'returns uuid, description and environments from show' do
    record = create(:project, organization: organization, description: 'Web stack')
    record.environments << production

    get "/api/v2/projects/#{record.uuid}", headers: headers

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to eq(
      'uuid' => record.uuid,
      'name' => record.name,
      'description' => 'Web stack',
      'environment_names' => %w[production],
      'environments' => %w[production]
    )
  end
end
