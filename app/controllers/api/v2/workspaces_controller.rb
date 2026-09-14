class Api::V2::WorkspacesController < Api::V2::ApplicationController
  before_action :set_workspace, only: %i[ show update destroy ]
  before_action :validate_project
  before_action :validate_token_scope
  before_action :log_api_query
  # before_action :set_project
  # before_action :set_workspace, only: %i[ show update destroy ]

  def index
    render json: @project.workspaces_json, status: :ok
  end

  def create
    @project.workspaces.new(item_params)
    if @project.save
      render json: { status: "updated" }, status: :created
    else
      render json: { status: "unprocessable_entity" }, status: :unprocessable_entity
    end
  end

  def show
    render json: { name: @workspace.name, description: @workspace.description }, status: :ok
  end

  def update
    logger.debug Workspace.all.map(&:name)
    @workspace.update(item_params)
    logger.debug @workspace.errors.full_messages
    if @workspace.update(item_params)
      render json: { status: "updated" }, status: :accepted
    else
      render json: { status: "Cannot update" }, status: :unprocessable_entity
    end
  end

  def destroy
    @workspace.destroy!
    head :no_content

    # render json: { status: "deleted" }, status: :no_content
  end

  private
    def item_params
      params.expect(workspace: [ :name, :description ])
    end

    def validate_scopes
      return unless [ "index", "create" ].include?(action_name)
      render json: { message: 'Parameter project_uuid is missing or invalid' }, status: 400 unless params[:project_uuid].present?
    end

    def set_workspace
      @workspace = Workspace.find_by(uuid: params[:uuid])
      render json: { message: 'This token do not allow you to access the project define by this UUID or the project is not existing' }, status: 404 if @workspace.nil?
    end

    def validate_project
      render json: { message: 'This token do not allow you to perform this action' }, status: 401 if scopable_type == "Workspace" and [ "index", "create" ].include?(action_name)

      if params[:project_uuid]
        @project = Project.find_by(uuid: params[:project_uuid])
      else
        @project = @workspace.project
      end   
    end

    def validate_token_scope
      if scopable_type == "Project"
        render json: { message: 'This token do not allow you to access the project define by this UUID or the project is not existing' }, status: 404 if @project != @token.scopable
      elsif scopable_type == "Organization"
        render json: { message: 'This token do not allow you to access the organization define by this UUID or the project is not existing' }, status: 404 if @token.scopable.projects.include?(@project) == false
      elsif scopable_type == "Workspace"
        render json: { message: 'This token do not allow you to access the workspace define by this UUID or the project is not existing' }, status: 404 if @token.scopable.project != @project
      end   
      
      @service_name = "Api"
      @serviceable = @workspace || @project || @organization
    end
end