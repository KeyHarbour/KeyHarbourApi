require 'swagger_helper'

RSpec.describe 'api/v2/license/instances', type: :request, openapi_spec: 'v2/openapi.yaml' do
  include_context 'license_token'
  let(:application) { create(:license_application, organization: organization) }
  let(:instance) { create(:license_instance, application: application) }
  let(:application_uuid) { application.uuid }

  path '/license/applications/{application_uuid}/instances' do
    get('get all instances for an application') do
      tags 'Instances'
      parameter name: 'application_uuid', in: :path, type: :string
      let(:application_uuid) { application.uuid } 
      response '200', 'Instances found' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              name: { type: :string },
              uuid: { type: :string },
            },
            required: [ 'name', 'uuid' ]
          }

        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end

    post('Create a new instance') do
      tags 'Instances'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'application_uuid', in: :path, type: :string
      let(:instance) { {name: "New Instance", short_name: "short", owner: "short"} }
      parameter name: :instance, in: :body, schema: {
        type: :object,
        properties: {
          instance: {
            type: :object,
            properties: {
              name: { type: :string },
              short_name: { type: :string },
              owner: { type: :string },
              renewal_date: { type: :date },
              seats: { type: :integer },
              unit_cost: { type: :number, format: :float }
            },
            required: [ 'name', 'short_name' ]
          }
        },
        required: [ 'instance' ]
      }
      let(:instance) { {name: "New Instance", short_name: "short", owner: "short"} }

      response '201', 'Instance created' do
        schema '$ref' => '#/components/schemas/Created'
        run_test!
      end

      response '400', 'Bad Request' do
        let(:instance) { "abc" } 
        run_test!
      end

      response '422', 'Unprocessable Entity' do   
        let(:instance) { {name: "New Instance"} }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end
  
  path '/license/instances/{uuid}' do
    get('get instance details') do
      tags 'Instances'
      produces 'application/json'
      parameter name: 'uuid', in: :path, type: :string
      let(:uuid) { instance.uuid } 

      response '200', 'Instance found' do
        schema type: :object,
          properties: {
            name: { type: :string },
            short_name: { type: :string },
            owner: { type: :string },
            renewal_date: { type: :date },
            seats: { type: :integer },
            unit_cost: { type: :number, format: :float },
            status: { 
              type: :string, 
              enum: ['active', 'disabled', 'archived'],
              example: 'active'
            }
          },
          required: [ 'name', 'owner', 'renewal_date', 'seats', 'status' ]

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
      tags 'Instances'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'uuid', in: :path, type: :string
      parameter name: :instance, in: :body, schema: {
        type: :object,
        properties: {
          instance: {
            type: :object,
            properties: {
              name: { type: :string },
              short_name: { type: :string },
              owner: { type: :string },
              renewal_date: { type: :date },
              seats: { type: :integer },
              unit_cost: { type: :number, format: :float },
              status: { 
                type: :string, 
                enum: ['active', 'disabled', 'archived']
              }
            },
            required: [ 'name', 'short_name', 'owner' ]
          }
        },
        required: [ 'instance' ]
      }

      let(:uuid) { instance.uuid } 

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
      tags 'Instances'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'uuid', in: :path, type: :string
      let(:uuid) { instance.uuid }

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
