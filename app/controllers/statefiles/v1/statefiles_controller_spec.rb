require "rails_helper"

RSpec.describe Statefiles::V1::StatefilesController, type: :controller do
  let(:organization) { create(:organization) }
  let(:project) { create(:project, organization: organization) }
  let(:environment) { create(:environment, organization: organization, name: "production") }
  let(:workspace) { create(:workspace, project: project, name: "testworkspace") }
  let(:token) { create(:token, scopable: project, environment: environment, expiration: 1.day.from_now) }
  let(:token_string) { token.generate_token_for(:statefile) }

  before do
    project.environments << environment
  end

  describe "authentication" do
    context "with valid Bearer token" do
      before do
        request.headers['Authorization'] = "Bearer #{token_string}"
      end

      it "authenticates successfully" do
        get :get, params: { project_id: project.uuid, workspace_uuid: workspace.uuid, environment: environment.name }
        expect(response).to have_http_status(:ok)
      end
    end

    context "with valid Basic Auth" do
      before do
        credentials = Base64.strict_encode64("username:#{token_string}")
        request.headers['Authorization'] = "Basic #{credentials}"
      end

      it "authenticates successfully" do
        get :get, params: { project_id: project.uuid, workspace_uuid: workspace.uuid, environment: environment.name }
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid token" do
      before do
        request.headers['Authorization'] = "Bearer invalid_token"
      end

      it "returns unauthorized" do
        get :get, params: { project_id: project.uuid, workspace_uuid: workspace.uuid, environment: environment.name }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq("Unauthorized")
      end
    end

    context "without token" do
      it "returns unauthorized" do
        get :get, params: { project_id: project.uuid, workspace_uuid: workspace.uuid, environment: environment.name }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET #get" do
    before do
      request.headers['Authorization'] = "Bearer #{token_string}"
    end

    context "when statefile exists" do
      let!(:statefile) { create(:statefile, workspace: workspace, environment: environment, content: '{"version":4,"resources":[]}') }

      it "returns the latest statefile content" do
        get :get, params: { project_id: project.uuid, workspace_uuid: workspace.uuid, environment: environment.name }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["version"]).to eq(4)
      end
    end

    context "when no statefile exists" do
      it "returns default empty statefile" do
        get :get, params: { project_id: project.uuid, workspace_uuid: workspace.uuid, environment: environment.name }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["version"]).to eq(4)
        expect(body["resources"]).to eq([])
      end
    end
  end

  describe "POST #update" do
    before do
      request.headers['Authorization'] = "Bearer #{token_string}"
    end

    it "creates new statefile" do
      content = '{"version":4,"resources":[{"type":"aws_instance"}]}'
      
      expect {
        post :update, params: { project_id: project.uuid, workspace_uuid: workspace.uuid, environment: environment.name }, body: content
      }.to change(Statefile, :count).by(1)
      
      expect(response).to have_http_status(:ok)
    end

    it "saves the content correctly" do
      content = '{"version":4,"resources":[{"type":"aws_instance"}]}'
      post :update, params: { project_id: project.uuid, workspace_uuid: workspace.uuid, environment: environment.name }, body: content
      
      statefile = workspace.statefiles.first
      # puts JSON.pretty_generate(JSON.parse(workspace.statefiles.to_json))
      expect(statefile.content).to eq(content)
    end
  end

  describe "POST #lock" do
    before do
      request.headers['Authorization'] = "Bearer #{token_string}"
    end

    context "when workspace is not locked" do
      it "creates a lock" do
        lock_params = {
          project_id: project.uuid,
          workspace_uuid: workspace.uuid,
          environment: environment.name,
          ID: "lock-123",
          Operation: "OperationTypeApply",
          Info: "test info",
          Who: "user@example.com",
          Version: "1.0",
          path: "test/path"
        }

        expect {
          post :lock, params: lock_params
        }.to change(StatefileLock, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(workspace.reload.statefile_lock).to be_present
        expect(workspace.statefile_lock.uuid).to eq("lock-123")
      end
    end

    context "when workspace is already locked" do
      let!(:existing_lock) { create(:statefile_lock, workspace: workspace, uuid: "existing-lock", who: "other@example.com") }

      it "returns conflict status" do
        lock_params = {
          project_id: project.uuid,
          workspace_uuid: workspace.uuid,
          environment: environment.name,
          ID: "new-lock",
          Operation: "OperationTypeApply",
          Who: "user@example.com"
        }

        post :lock, params: lock_params
        
        expect(response).to have_http_status(:conflict)
        body = JSON.parse(response.body)
        expect(body["ID"]).to eq("existing-lock")
        expect(body["Who"]).to eq("other@example.com")
      end
    end
  end

  describe "DELETE #unlock" do
    before do
      request.headers['Authorization'] = "Bearer #{token_string}"
    end

    context "when workspace is locked" do
      let!(:lock) { create(:statefile_lock, workspace: workspace, uuid: "lock-123") }

      it "removes the lock" do
        expect {
          delete :unlock, params: { project_id: project.uuid, workspace_uuid: workspace.uuid, environment: environment.name }
        }.to change(StatefileLock, :count).by(-1)

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["ID"]).to eq("lock-123")
      end
    end

    context "when workspace is not locked" do
      it "returns conflict status" do
        delete :unlock, params: { project_id: project.uuid, workspace_uuid: workspace.uuid, environment: environment.name }
        
        expect(response).to have_http_status(:conflict)
        expect(JSON.parse(response.body)["error"]).to eq("Not Found")
      end
    end
  end

  describe "#bearer_token" do
    it "extracts token from Bearer auth" do
      request.headers['Authorization'] = "Bearer test_token_123"
      expect(controller.bearer_token).to eq("test_token_123")
    end

    it "extracts token from Basic auth password field" do
      credentials = Base64.strict_encode64("username:password_token")
      request.headers['Authorization'] = "Basic #{credentials}"
      expect(controller.bearer_token).to eq("password_token")
    end

    it "returns nil without authorization header" do
      expect(controller.bearer_token).to be_nil
    end
  end
end
