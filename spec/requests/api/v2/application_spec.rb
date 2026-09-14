require 'swagger_helper'

RSpec.describe 'application', type: :request, openapi_spec: 'v2/openapi.yaml' do

  path '/auth' do

    get('auth application') do
      tags 'Authentification'
      produces 'application/json'

      security [ bearerAuth: [] ]

      let(:mock_token) { 'mocked.token' }

      response '200', 'Access granted' do
        let(:Authorization) { "Bearer #{mock_token}" }

        before do
          allow_any_instance_of(Api::V2::ApplicationController)
            .to receive(:authenticate_token!)
            .and_return(true)
        end

        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }

        run_test!
      end
    end
  end
end
