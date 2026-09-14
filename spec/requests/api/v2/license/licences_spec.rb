require 'swagger_helper'

RSpec.describe 'Application', type: :request, openapi_spec: 'v2/openapi.yaml' do
  let(:token) {create(:token, :without_environment)}

  path '/license/auth' do

    get('auth application') do
      tags 'Authentification'
      produces 'application/json'

      security [ bearerAuth: [] ]

      let(:mock_token) { token.generate_token_for(:statefile) }

      response '200', 'Access granted' do
        let(:Authorization) { "Bearer #{mock_token}" }

        run_test!
      end

      response '401', 'Unauthorized' do
        let(:token) {create(:token, :for_organization)}
        let(:mock_token) { token.generate_token_for(:statefile) }
        let(:Authorization) { "Bearer #{mock_token}" }

        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }

        run_test!
      end
    end
  end
end
