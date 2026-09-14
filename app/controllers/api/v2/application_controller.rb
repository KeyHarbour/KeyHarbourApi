class Api::V2::ApplicationController < ActionController::API
  # API controllers should not use CSRF cookies; rely on bearer auth instead
  before_action :authenticate_token!
  before_action :validate_scopes
  attr_accessor :scopable_type, :project, :environment

  def auth
    render json: { message: "Allowed access" }, status: :ok
  end

  def authenticate_token!
    # logger.debug request.headers['Authorization']
    @token = Token.check(bearer_token)

    if @token.nil?
      render json: { message: 'Invalid or outdated token. Unauthorized' }, status: 401 
    else
      self.scopable_type = @token.scopable_type
      @environment = @token.environment
    end
    # @project = @token.scopable if @token.scopable_type == "Project"
    # @project = Project.find_by(uuid: params[:uuid])  if @token.scopable_type == "Organization"
    # @environment = @token.environment
  end

  private

  def validate_scopes
  end

  def bearer_token
    auth_header = request.headers['Authorization']
    logger.debug "Authorization Header: #{auth_header}"
    return nil unless auth_header&.start_with?('Bearer ')
    
    auth_header.split(' ').last
  end
  
  def log_api_query
    ApiQuery.create!(
      serviceable: @serviceable,
      controller: params[:controller],
      action: params[:action],
      token: @token.id,
      date: Time.current,
      service_name: @service_name
    )
  end
end