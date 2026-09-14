require 'swagger_helper'

RSpec.describe 'api/v2/license/licensees', type: :request, openapi_spec: 'v2/openapi.yaml' do
  include_context 'license_token'
  let(:application) { create(:license_application, organization: organization) }
  let(:instance) { create(:license_instance, application: application) }
  let(:licensee) { create(:license_licensee, instance: instance) }
  let(:instance_uuid) { instance.uuid }

  path '/license/instances/{instance_uuid}/licensees' do
    get('get all licensees for an instance') do
      tags 'Licensees'
      parameter name: 'instance_uuid', in: :path, type: :string
      let(:instance_uuid) { instance.uuid } 
      response '200', 'Licensees found' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              uuid: { type: :string },
            },
            required: [ 'uuid' ]
          }

        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end

    post('Create a new license') do
      tags 'Licensees'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'instance_uuid', in: :path, type: :string
      let(:licensee) { {uuid: Faker::Internet.uuid } }
      parameter name: :licensee, in: :body, schema: {
        type: :object,
        properties: {
          licensee: {
            type: :object,
            properties: {
              uuid: { type: :string }
            },
            required: [ 'uuid' ]
          }
        },
        required: [ 'licensee' ]
      }

      response '201', 'Instance created' do
        schema '$ref' => '#/components/schemas/Created'
        run_test!
      end

      response '422', 'Unprocessable Entity' do   
        let(:licensee) { {name: 'abc'} }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end
  
  path '/license/licensees/{uuid}' do
    get('get licensee details') do
      tags 'Licensees'
      produces 'application/json'
      parameter name: 'uuid', in: :path, type: :string
      let(:uuid) { licensee.uuid } 

      response '200', 'Instance found' do
        schema type: :object,
          properties: {
            uuid: { type: :string },
            status: { 
              type: :string, 
              enum: ['active', 'disabled', 'archived'],
              example: 'active'
            }
          },
          required: [ 'uuid', 'status' ]

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

    patch('update instance detail') do
      tags 'Licensees'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'uuid', in: :path, type: :string
      parameter name: :licensee, in: :body, schema: {
        type: :object,
        properties: {
          instance: {
            type: :object,
            properties: {
              uuid: { type: :string },
              status: { 
                type: :string, 
                enum: ['active', 'disabled', 'archived']
              }
            },
            required: [ 'uuid' ]
          }
        },
        required: [ 'licensee' ]
      }

      let(:uuid) { licensee.uuid } 

      response '202', 'Application updated' do
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
    
    delete('Delete a instance') do
      tags 'Licensees'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'uuid', in: :path, type: :string
      let(:uuid) { licensee.uuid }

      response '204', 'no content' do
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
        let(:Authorization) { nil }
        run_test!
      end
    end    
  end
end
