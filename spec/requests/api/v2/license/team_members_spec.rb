require 'swagger_helper'

RSpec.describe 'api/v2/license/team_members', type: :request, openapi_spec: 'v2/openapi.yaml' do
  include_context 'license_token'
  let(:team_member) { create(:license_team_member, organization: organization) }
  let(:team_member_uuid) { team_member.uuid }

  path '/license/team_members' do
    # get('get all licensees for an instance') do
    #   tags 'License Team Members'
    #   response '200', 'Licensees found' do
    #     schema type: :array,
    #       items: {
    #         type: :object,
    #         properties: {
    #           uuid: { type: :string },
    #           manager_uuid: { type: :string }
    #         },
    #         required: [ 'uuid' ]
    #       }

    #     run_test!
    #   end

    #   response '401', 'Unauthorized' do
    #     let(:Authorization) { nil }
    #     run_test!
    #   end
    # end

    # post('Create a new license') do
    #   tags 'Licensees'
    #   produces 'application/json'
    #   consumes 'application/json'
    #   let(:team_member) { {uuid: Faker::Internet.uuid } }
    #   parameter name: :team_member, in: :body, schema: {
    #     type: :object,
    #     properties: {
    #       team_member: {
    #         type: :object,
    #         properties: {
    #           uuid: { type: :string }
    #         },
    #         required: [ 'uuid' ]
    #       }
    #     },
    #     required: [ 'team_member' ]
    #   }

    #   response '201', 'team_member created' do
    #     schema '$ref' => '#/components/schemas/Created'
    #     run_test!
    #   end

    #   response '201', 'team_member created with parent' do
    #     let(:m_uuid) { Faker::Internet.uuid }
    #     let(:tm_uuid) { Faker::Internet.uuid }
    #     let(:team_member) { {uuid: tm_uuid, manager_uuid: m_uuid } }
    #     schema '$ref' => '#/components/schemas/Created'
    #     run_test! do |response|
    #       member = License::TeamMember.find_by(uuid: tm_uuid)
    #       expect(member).to be_present
          
    #       expect(member.manager).to be_present
    #       expect(member.manager.uuid).to eq(m_uuid)
          
    #       expect(member.manager.organization_id).to eq(member.organization_id)
    #     end
    #   end

    #   response '422', 'Unprocessable Entity' do   
    #     let(:team_member) { {uuid: nil} }
    #     run_test!
    #   end

    #   response '401', 'Unauthorized' do
    #     let(:Authorization) { nil }
    #     run_test!
    #   end
    # end
  end
  
  path '/license/team_members/{uuid}' do
    # get('get team_member details') do
    #   tags 'License Team Members'
    #   produces 'application/json'
    #   parameter name: 'uuid', in: :path, type: :string
    #   let(:team_member) { create(:license_team_member, organization: organization) }
    #   let(:uuid) { team_member.uuid } 

    #   response '200', 'Instance found' do
    #     schema type: :object,
    #       properties: {
    #         uuid: { type: :string },
    #         manager_uuid: { type: [:string, :null], nullable: true }
    #       },
    #       required: [ 'uuid', 'manager_uuid' ]

    #     run_test!
    #   end

    #   response '404', 'Not found' do
    #     let(:uuid) { "abc" } 
    #     run_test!
    #   end

    #   response '401', 'Unauthorized' do
    #     let(:Authorization) { nil }
    #     run_test!
    #   end
    # end

    patch('update team_member detail') do
      tags 'License Team Members'
      produces 'application/json'
      consumes 'application/json'
      parameter name: 'uuid', in: :path, type: :string
      parameter name: :team_member, in: :body, schema: {
        type: :object,
        properties: {
          team_member: {
            type: :object,
            properties: {
              uuid: { type: :string },
              manager_uuid: { type: :string }
            },
            required: [ 'uuid', 'manager_uuid' ]
          }
        },
        required: [ 'team_member' ]
      }

      let(:uuid) { team_member.uuid } 

      response '202', 'Application updated' do
        schema '$ref' => '#/components/schemas/Updated'
        run_test!
      end

      # response '404', 'Not found' do
      #   let(:uuid) { "abc" } 
      #   run_test!
      # end

      # response '401', 'Unauthorized' do
      #   let(:Authorization) { nil }
      #   run_test!
      # end
    end  
    
    # delete('Delete a team_member') do
    #   tags 'License Team Members'
    #   produces 'application/json'
    #   consumes 'application/json'
    #   parameter name: 'uuid', in: :path, type: :string
    #   let(:uuid) { team_member.uuid }

    #   response '204', 'no content' do
    #     run_test! do |response|
    #       expect(response.body).to be_blank
    #       expect(response.status).to eq(204)
    #     end
    #   end

    #   response '404', 'Not found' do
    #     let(:uuid) { "NOT-EXIST" }
    #     run_test!
    #   end

    #   response '401', 'Unauthorized' do
    #     let(:Authorization) { nil }
    #     run_test!
    #   end
    # end    
  end
end
