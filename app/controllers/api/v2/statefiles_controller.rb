class Api::V2::StatefilesController < Api::V2::ApplicationController
  before_action :set_workspace
  before_action :set_statefile
  before_action :validate_token_scope
  before_action :log_api_query

  def index
    render json: @workspace.statefiles_json(environment: environment), status: :ok
  end

  def delete_all
    @workspace.statefiles.where(environment: environment).delete_all
    head :no_content
  end

  def create
    @statefile = @workspace.statefiles.new(item_params)
    @statefile.published_at = DateTime.now.utc
    @statefile.environment =  @environment
    Rails.logger.info @statefile.attributes
    if @statefile.save
      render json: { status: "created" }, status: :created
    else
      logger.debug @statefile.errors.to_yaml
      render json: { status: "unprocessable_entity" }, status: :unprocessable_entity
    end
  end

  def last
    if @workspace.statefiles.count == 0
      render json: { status: "not_found" }, status: :not_found
    else
      statefile = @workspace.statefiles.first
      render json: { content: statefile.content, published_at: statefile.published_at }, status: :ok
    end
  end

  def show
    render json: { content: @statefile.content, published_at: @statefile.published_at }, status: :ok
  end

  def destroy
    @statefile.destroy!
    head :no_content
  end

  private
    def item_params
      content = params[:content]
      if content.blank? && params[:statefile].present?
        content = params[:statefile][:content]
      end
      { content: content }
    end

    def set_workspace
      return unless params[:workspace_uuid].present?

      @workspace = Workspace.find_by(uuid: params[:workspace_uuid])

      if @workspace.nil?
        render json: { message: 'This token do not allow you to access the workspace define by this UUID or the workspace is not existing' }, status: 404
      else
        @project = @workspace.project
      end
    end

    def set_statefile
      return unless params[:uuid].present?
      
      @statefile = Statefile.find_by(uuid: params[:uuid])
      if @statefile.nil?
        render json: { message: 'This token do not allow you to access the statefile define by this UUID or the statefile is not existing' }, status: 404
      else
        @workspace = @statefile.workspace
        @project = @workspace.project
      end
    end

    def validate_token_scope
      if scopable_type == "Project"
        render json: { message: 'This token do not allow you to access the workspace define by this UUID or the workspace is not existing' }, status: 404 if @project != @token.scopable
      elsif scopable_type == "Organization"
        render json: { message: 'This token do not allow you to access the workspace define by this UUID or the workspace is not existing' }, status: 404 if @token.scopable.projects.include?(@project) == false
      elsif scopable_type == "Workspace"
        render json: { message: 'This token do not allow you to access the workspace define by this UUID or the workspace is not existing' }, status: 404 if @token.scopable != @workspace
      end   
      
      @service_name = "Statefile"
      @serviceable = @workspace
    end
end