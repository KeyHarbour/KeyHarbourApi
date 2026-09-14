class Api::V2::TrustAssetsController < Api::V2::ApplicationController
  before_action :set_workspace
  before_action :set_trust_asset, only: %i[ show update destroy ]
  before_action :validate_token_scope
  before_action :log_api_query

  def index
    result = @workspace.trust_assets.active.for_environment(@environment)
    render json: TrustAsset.as_json_api(result), status: :ok
  end

  def create
    @trust_asset = @workspace.trust_assets.new(item_params)
    @trust_asset.environment =  @environment
    if @trust_asset.save
      render json: { status: "created" }, status: :created
    else
      render json: { status: "unprocessable_entity" }, status: :unprocessable_entity
    end
  end

  def show
    result = @workspace.trust_assets.where(name: params[:name]).active.for_environment(@environment)
    render json: TrustAsset.as_json_api(result), status: :ok
  end

  def update
    if @trust_asset.update(item_params)
      logger.debug @trust_asset.attributes
      logger.debug @trust_asset.errors.full_messages
      render json: { status: "updated" }, status: :accepted
    else
      logger.debug @trust_asset.attributes
      logger.debug @trust_asset.errors.full_messages
      render json: { status: "Cannot update" }, status: :unprocessable_entity
    end
  end

  def destroy
    @trust_asset.destroy!
    head :no_content

    # render json: { status: "deleted" }, status: :no_content
  end

  private

  def item_params
    params.fetch(:trust_asset, params)
          .permit(:name, :issuer, :expires_at, :format, :consumer, :description, :reminder_days)
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

  def set_trust_asset
    return unless params[:name].present?

    @trust_asset = @token.scopable.trust_assets.active.for_environment(@environment).find_by(name: params[:name])
    if @trust_asset.nil?
      logger.debug "Halted here"
      render json: { message: 'This token do not allow you to access the trust asset define by this UUID or the trust asset is not existing' }, status: 404
    else
      @workspace = @trust_asset.workspace
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
    @service_name = "TrustAsset"
    @serviceable = @workspace
  end
end
