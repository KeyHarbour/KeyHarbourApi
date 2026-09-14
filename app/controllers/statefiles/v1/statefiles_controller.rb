class Statefiles::V1::StatefilesController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :authenticate_token
  before_action :log_api_query

  def bearer_token
    auth_header = request.headers['Authorization']
    if auth_header&.start_with?('Basic ')
      logger.debug "Basic Auth detected, skipping Bearer token extraction"
      base64_credentials = auth_header.split(' ', 2).last
      decoded = Base64.decode64(base64_credentials)
      username, password = decoded.split(':', 2)
      logger.debug "Username: #{username}, Password: #{password}"
      return password
    end

    logger.debug "Authorization Header: #{auth_header}"
    return nil unless auth_header&.start_with?('Bearer ')
    
    auth_header.split(' ').last
  end

  def authenticate_token
    @workspace = Token.find_workspace_by_token(params[:workspace_uuid], bearer_token)
    if @workspace.nil?
      render json: { error: 'Unauthorized' }, status: 401
      return
    end

    @project = @workspace.project
    @organization = @project.organization
    @environment = @project.environments.where("LOWER(name) = LOWER(?)", params[:environment]).first
  end

  def lock
    if @workspace.statefile_lock.nil?
      @workspace.statefile_lock ||= StatefileLock.new
      @workspace.statefile_lock.locked_at = DateTime.now.utc
      @workspace.statefile_lock.uuid = params["ID"]
      @workspace.statefile_lock.operation = params["Operation"]
      @workspace.statefile_lock.info = params["Info"]
      @workspace.statefile_lock.who = params["Who"]
      @workspace.statefile_lock.version = params["Version"]
      @workspace.statefile_lock.path = params["path"]
      @workspace.statefile_lock.save!
      render json: { error: 'Unauthorized' }, status: 200
    else
      result = {
        "ID": @workspace.statefile_lock.uuid,
        "Who": @workspace.statefile_lock.who,
        "Operation": @workspace.statefile_lock.operation,
        "Created": @workspace.statefile_lock.created_at.iso8601,
        "Info": @workspace.statefile_lock.info,
        "Path":  @workspace.statefile_lock.path
      }
      render json: result, status: 409
    end
  end

  def unlock
    if @workspace.statefile_lock.nil?
      render json: { error: 'Not Found' }, status: 409
    else
      uuid = @workspace.statefile_lock.uuid
      @workspace.statefile_lock&.destroy
      render json: { ID: uuid }, status: 200
    end
  end

  def get
    statefile = @workspace.statefiles.order(published_at: :desc, created_at: :desc).first
    content_to_send = statefile ? statefile.content : { "version" => 4, "resources" => [] }
    render json: content_to_send, status: :ok
  end

  def update
    @statefile = @workspace.statefiles.find_or_initialize_by(published_at: DateTime.now.utc, environment: @environment)
    @statefile.content = request.raw_post
    @statefile.save!
    statefile = {}
    render json: nil, status: :ok
  end
  
  def log_api_query
    ApiQuery.create!(
      serviceable: @workspace,
      controller: params[:controller],
      action: params[:action],
      token: @token&.id || 0,
      date: Time.current,
      service_name: 'Statefile'
    )
  end
end