require 'swagger_helper'

RSpec.describe 'Statefiles::V1::Statefiles', type: :request, openapi_spec: 'statefile_v1/openapi.yaml' do
  let(:project) { create(:project) }
  let(:organization) { project.organization }
  let(:environment) { create(:environment, organization: organization) }
  let(:workspace) { create(:workspace, project: project) }
  let(:token_workspace) { create(:token_workspace, scopable: workspace) }
  let(:valid_token) { 'secret-terraform-token' }

  let(:workspace_uuid) { workspace.uuid }
  let(:environment_name) { environment.name }

  let(:Authorization) { "Bearer #{valid_token}" }

  before do
    project.environments << environment
    allow(TokenWorkspace).to receive(:find_workspace_by_token).and_return(nil)
    allow(TokenWorkspace).to receive(:find_workspace_by_token)
      .with(workspace.uuid, valid_token)
      .and_return(workspace)
  end

  # Note : Si votre serveur dans swagger_helper.rb a déjà "/statefiles/v1" dans son URL,
  # utilisez '/{workspace_uuid}/{environment_name}'. Sinon, gardez le préfixe complet ci-dessous.
  path '{workspace_uuid}/{environment_name}' do
    parameter name: :workspace_uuid, in: :path, type: :string, description: 'UUID du workspace'
    parameter name: :environment_name, in: :path, type: :string, description: "Nom de l'environnement"
    parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer <token> ou Basic <base64>'

    # =========================================================================
    # GET #get (Récupération du statefile + tests d'authentification & logging)
    # =========================================================================
    get('Récupère le statefile Terraform') do
      tags 'Statefiles'
      produces 'application/json'
      security [{ bearer_auth: [] }, { basic_auth: [] }]

      response(200, 'Statefile vierge par défaut quand aucun statefile n\'existe') do
        run_test! do |response|
          expect(JSON.parse(response.body)).to eq({
            'version' => 4,
            'resources' => []
          })
        end
      end

      response(200, 'Statefile le plus récent retourné') do
        let!(:old_state) do
          create(:statefile, workspace: workspace, content: { 'version' => 4, 'serial' => 1 }.to_json, published_at: 2.days.ago)
        end
        let!(:latest_state) do
          create(:statefile, workspace: workspace, content: { 'version' => 4, 'serial' => 2 }.to_json, published_at: 1.hour.ago)
        end

        run_test! do |response|
          expect(JSON.parse(response.body)).to eq({
            'version' => 4,
            'serial' => 2
          })
        end
      end

      response(200, 'Authentification via Basic Auth (format standard Terraform)') do
        let(:Authorization) { "Basic #{Base64.strict_encode64("terraform:#{valid_token}")}" }

        run_test!
      end

      response(200, 'Enregistre une requête dans ApiQuery') do
        it 'crée un ApiQuery lors de l\'appel' do |example|
          expect {
            submit_request(example.metadata)
          }.to change(ApiQuery, :count).by(1)

          assert_response_matches_metadata(example.metadata)
          query = ApiQuery.last
          expect(query.serviceable).to eq(workspace)
          expect(query.service_name).to eq('statefile')
        end
      end

      response(401, 'Non autorisé (Token invalide ou manquant)') do
        let(:Authorization) { 'Bearer mauvais-token' }

        run_test! do |response|
          expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized' })
        end
      end
    end

    # =========================================================================
    # POST #update (Mise à jour du statefile)
    # =========================================================================
    post('Met à jour ou crée un statefile Terraform') do
      tags 'Statefiles'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer_auth: [] }, { basic_auth: [] }]

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          version: { type: :integer, example: 4 },
          terraform_version: { type: :string, example: '1.5.0' },
          serial: { type: :integer, example: 3 }
        },
        required: %w[version]
      }

      response(200, 'Statefile enregistré avec succès') do
        let(:payload) { { version: 4, terraform_version: '1.5.0', serial: 3 } }

        it 'crée un nouveau statefile avec le contenu brut de la requête' do |example|
          expect {
            submit_request(example.metadata)
          }.to change(workspace.statefiles, :count).by(1)

          assert_response_matches_metadata(example.metadata)

          created_state = workspace.statefiles.last
          expect(created_state.content).to eq(payload.to_json)
          expect(created_state.environment).to eq(environment)
        end
      end
    end

    # =========================================================================
    # PUT #lock (Verrouillage du statefile)
    # =========================================================================
    put('Verrouille le statefile') do
      tags 'Statefiles'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer_auth: [] }, { basic_auth: [] }]

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          ID: { type: :string, example: 'lock-uuid-1234' },
          Operation: { type: :string, example: 'OperationTypeApply' },
          Info: { type: :string, example: 'Applying changes' },
          Who: { type: :string, example: 'user@domain.com' },
          Version: { type: :string, example: '1.5.0' },
          path: { type: :string, example: 'tfstate' }
        }
      }

      let(:payload) do
        {
          'ID' => 'lock-uuid-1234',
          'Operation' => 'OperationTypeApply',
          'Info' => 'Applying changes',
          'Who' => 'user@domain.com',
          'Version' => '1.5.0',
          'path' => 'tfstate'
        }
      end

      response(200, 'Workspace verrouillé avec succès') do
        it 'crée un StatefileLock et retourne 200' do |example|
          expect {
            submit_request(example.metadata)
          }.to change(StatefileLock, :count).by(1)

          assert_response_matches_metadata(example.metadata)

          lock = workspace.reload.statefile_lock
          expect(lock.uuid).to eq('lock-uuid-1234')
          expect(lock.who).to eq('user@domain.com')
          expect(lock.operation).to eq('OperationTypeApply')
        end
      end

      response(409, 'Conflit : le workspace est déjà verrouillé') do
        let!(:existing_lock) do
          create(:statefile_lock,
                 workspace: workspace,
                 uuid: 'existing-lock-999',
                 who: 'other@domain.com',
                 operation: 'OperationTypePlan',
                 info: 'Planning',
                 path: 'tfstate')
        end

        it 'ne crée pas de verrou et retourne les infos du verrou existant' do |example|
          expect {
            submit_request(example.metadata)
          }.not_to change(StatefileLock, :count)

          assert_response_matches_metadata(example.metadata)

          json = JSON.parse(response.body)
          expect(json['ID']).to eq('existing-lock-999')
          expect(json['Who']).to eq('other@domain.com')
          expect(json['Operation']).to eq('OperationTypePlan')
        end
      end
    end

    # =========================================================================
    # DELETE #unlock (Déverrouillage du statefile)
    # =========================================================================
    delete('Déverrouille le statefile') do
      tags 'Statefiles'
      produces 'application/json'
      security [{ bearer_auth: [] }, { basic_auth: [] }]

      response(200, 'Verrou supprimé avec succès') do
        let!(:existing_lock) { create(:statefile_lock, workspace: workspace, uuid: 'lock-to-delete') }

        it 'supprime le verrou et retourne son ID avec un statut 200' do |example|
          expect {
            submit_request(example.metadata)
          }.to change(StatefileLock, :count).by(-1)

          assert_response_matches_metadata(example.metadata)
          expect(JSON.parse(response.body)).to eq({ 'ID' => 'lock-to-delete' })
        end
      end

      response(409, 'Aucun verrou trouvé à supprimer') do
        run_test! do |response|
          expect(JSON.parse(response.body)).to eq({ 'error' => 'Not Found' })
        end
      end
    end
  end
end
