class Api::V2::KeyValueStoresController < Api::V2::ApplicationController
  before_action :set_workspace
  before_action :set_keystore, only: %i[ show update destroy ]
  before_action :validate_token_scope
  before_action :log_api_query

  def index
    result = @workspace.key_value_stores.active.for_environment(@environment)
    render json: KeyValueStore.as_json_api(result), status: :ok
  end

  def create
    @keyvalue = @workspace.key_value_stores.new(item_params)
    @keyvalue.environment =  @environment
    if @keyvalue.save
      render json: { status: "created" }, status: :created
    else
      render json: { status: "unprocessable_entity" }, status: :unprocessable_entity
    end
  end

  def show
    if @keyvalue.value_file.attached?
      content = @keyvalue.value_file.download
      content_type = @keyvalue.value_file.content_type
    else
      content = @keyvalue.value
      content_type = "text/plain"
    end
    @keyvalue.destroy! if @keyvalue.one_time_only == true
    send_data content, 
              filename: @keyvalue.key, 
              type: 'application/octet-stream', 
              content_type: content_type,
              disposition: 'inline'
  end

  def update
    if @keyvalue.update(item_params)
      render json: { status: "updated" }, status: :accepted
    else
      render json: { status: "Cannot update" }, status: :unprocessable_entity
    end
  end

  def destroy
    @keyvalue.destroy!
    head :no_content

    # render json: { status: "deleted" }, status: :no_content
  end

  private

    def item_params
      params.fetch(:key_value_store, params)
            .permit(:key, :value, :expires_at, :private, :one_time_only, :value_file)
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

    def set_keystore
      return unless params[:key].present?

      @keyvalue = @token.scopable.key_value_stores.active.for_environment(@environment).find_by(key: params[:key])
      if @keyvalue.nil?
        logger.debug "Halted here"
        render json: { message: 'This token do not allow you to access the key value store define by this UUID or the key value store is not existing' }, status: 404
      else
        @workspace = @keyvalue.workspace
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
      @service_name = "KeyValueStore"
      @serviceable = @workspace
    end
end
