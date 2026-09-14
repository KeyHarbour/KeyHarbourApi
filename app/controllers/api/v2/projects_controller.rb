class Api::V2::ProjectsController < Api::V2::ApplicationController
  before_action :validate_project
  before_action :validate_org
  before_action :log_api_query

  def index
    render json: @organization.projects_json, status: :ok
  end

  def create
    @organization.projects.new(item_params)
    if @organization.save
      render json: { status: "updated" }, status: :created
    else
      render json: { status: "unprocessable_entity" }, status: :unprocessable_entity
    end
  end

  def show
    render json: { name: project.name, environments: project.environment_names }, status: :ok
  end

  def update
    if project.update(item_params)
      render json: { status: "updated" }, status: :accepted
    else
      render json: { status: "Cannot update" }, status: :unprocessable_entity
    end
  end

  private
    def item_params
      params.expect(project: [ :name, :uuid, :description, environment_ids: [] ])
    end

    def validate_scopes
      render json: { message: 'This token do not allow you to perform this action' }, status: 401 if scopable_type != "Organization" && [ "index", "create" ].include?(action_name)
    end

    def validate_project
      return unless params[:uuid].present?
      
      @project = Project.find_by(uuid: params[:uuid])
      render json: { message: '004 - This token do not allow you to access the project define by this UUID or the project is not existing' }, status: 404 unless @project
    end

    def validate_org
      if params[:organization_uuid].present?
        @organization = Organization.find_by(uuid: params[:organization_uuid]) 
      else
        @organization = @project.organization
      end
      if scopable_type == "Organization"
        render json: { message: '001 - This token do not allow you to access the projects organization define by this UUID or the project is not existing' }, status: 404 unless @token.scopable == @organization
      elsif scopable_type == "Project"
        render json: { message: '002 - This token do not allow you to access the project define by this UUID or the project is not existing' }, status: 404 if @project != @token.scopable
      else
        render json: { message: '003 - This token do not allow you to access the project define by this UUID or the project is not existing' }, status: 404
      end
      @service_name = "Api"
      @serviceable = @project || @organization
    end
end