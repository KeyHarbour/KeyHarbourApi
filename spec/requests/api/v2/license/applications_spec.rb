require 'swagger_helper'

RSpec.describe 'api/v2/license/applications', type: :request, openapi_spec: 'v2/openapi.yaml' do
  include_context 'license_token'
  let(:application) { create(:license_application, organization: organization) }

  path '/license/applications' do

    get('get all apps for an organization') do
      tags 'Applications'
      response '200', 'Apps found' do
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
    end

    post('Create a new application') do
      tags 'Applications'
      produces 'application/json'
      consumes 'application/json'
      parameter name: :application, in: :body, schema: {
        type: :object,
        properties: {
          application: {
            type: :object,
            properties: {
              name: { type: :string },
              short_name: { type: :string },
              owner: { type: :string },
              renewal_date: { type: :date },
              vendor: { type: :string },
              tier: { type: :string },
              seats: { type: :integer },
              unit_cost: { type: :number, format: :float },
            },
            required: [ 'name', 'short_name', 'owner', 'vendor' ]
          }
        },
        required: [ 'application' ]
      }
      response '201', 'Application created' do
        let(:application) { {name: "New Application", short_name: "short", owner: "short", vendor: "short"} }
        schema '$ref' => '#/components/schemas/Created'
        run_test!
      end

      response '400', 'Bad Request' do
        let(:application) { "abc" } 
        run_test!
      end

      response '422', 'Unprocessable Entity' do   
        let(:application) { {name: "New Application"} }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end
  
  path '/license/applications/{uuid}' do
    get('get application details') do
      tags 'Applications'
      produces 'application/json'
      parameter name: 'uuid', in: :path, type: :string

      let(:uuid) { application.uuid } 

      response '200', 'Application found' do
        schema type: :object,
          properties: {
            name: { type: :string },
            short_name: { type: :string },
            owner: { type: :string },
            renewal_date: { type: :date },
            vendor: { type: :string },
            tier: { type: :string },
            seats: { type: :integer },
            unit_cost: { type: :number, format: :float },
            status: { 
              type: :string, 
              enum: ['active', 'disabled', 'archived'],
              example: 'active'
            }
          },
          required: [ 'name', 'owner', 'renewal_date', 'vendor', 'tier', 'seats', 'status' ]

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

    patch('update application detail') do
      tags 'Applications'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'uuid', in: :path, type: :string
      parameter name: :application, in: :body, schema: {
        type: :object,
        properties: {
          application: {
            type: :object,
            properties: {
              name: { type: :string },
              short_name: { type: :string },
              owner: { type: :string },
              renewal_date: { type: :date },
              vendor: { type: :string },
              tier: { type: :string },
              seats: { type: :integer },
              unit_cost: { type: :number, format: :float },
              status: { 
                type: :string, 
                enum: ['active', 'disabled', 'archived']
              }
            },
            required: [ 'name', 'short_name', 'owner', 'vendor' ]
          }
        },
        required: [ 'application' ]
      }

      let(:uuid) { application.uuid } 

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
    
    delete('Delete a workspace') do
      tags 'Applications'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'uuid', in: :path, type: :string
      let(:uuid) { application.uuid }

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
