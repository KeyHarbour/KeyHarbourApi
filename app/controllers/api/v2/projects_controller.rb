class Api::V2::ProjectsController < Api::V2::ApplicationController
  # environment_names is not a column, so list the wrapped keys explicitly:
  # an unwrapped JSON body keeps its environment names.
  wrap_parameters :project, include: %i[name uuid description environment_ids environment_names], format: [ :json ]

  before_action :validate_project
  before_action :validate_org
  before_action :log_api_query

  def index
    render json: @organization.projects_json, status: :ok
  end

  def create
    attributes = project_attributes
    return if performed?

    new_project = @organization.projects.new(attributes)
    if new_project.save
      render json: project_json(new_project).merge(status: "created"), status: :created
    else
      render json: { status: "unprocessable_entity" }, status: :unprocessable_entity
    end
  end

  def show
    render json: project_json(project), status: :ok
  end

  def update
    attributes = project_attributes
    return if performed?

    if project.update(attributes)
      render json: { status: "updated" }, status: :accepted
    else
      render json: { status: "Cannot update" }, status: :unprocessable_entity
    end
  end

  private
    def item_params
      params.expect(project: [ :name, :uuid, :description, environment_ids: [], environment_names: [] ])
    end

    # Accepts environments by name (as documented) as well as by id. Names are
    # matched case-insensitively against the organization's environments; an
    # unknown name is rejected instead of being silently dropped.
    def project_attributes
      attributes = item_params
      names = attributes.delete(:environment_names)
      return attributes if names.nil?

      environments = @organization.environments.where("LOWER(name) IN (?)", names.map { |name| name.to_s.downcase })
      unknown = names.reject { |name| environments.any? { |environment| environment.name.casecmp?(name.to_s) } }
      if unknown.any?
        render json: {
          message: "Unknown environment(s): #{unknown.join(', ')}",
          available_environments: @organization.environments.pluck(:name)
        }, status: :unprocessable_entity
        return
      end

      attributes.merge(environment_ids: environments.map(&:id))
    end

    # "environments" is kept alongside the documented "environment_names" for
    # clients that read the old key.
    def project_json(record)
      names = record.environment_names
      {
        uuid: record.uuid,
        name: record.name,
        description: record.description,
        environment_names: names,
        environments: names
      }
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
        render json: { message: '002 - This token do not allow you to access the project define by this UUID or the project is not existing' }, status: 401 if @project != @token.scopable
      else
        render json: { message: '003 - This token do not allow you to access the project define by this UUID or the project is not existing' }, status: 404
      end
      @service_name = "Api"
      @serviceable = @project || @organization
    end
end