class Api::V2::ApplicationController < ActionController::API
  before_action :authenticate_token!
  attr_accessor :scopable_type, :project, :environment

  def auth
    render json: { message: "Allowed access" }, status: :ok
  end

  def authenticate_token!
    @token = Token.check(bearer_token)
    logger.debug "Token: #{@token}"

    if @token.nil?
      render json: { message: 'Invalid or outdated token. Unauthorized' }, status: 401 
    else
      self.scopable_type = @token.scopable_type
      @environment = @token.environment
    end
  end

  private

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