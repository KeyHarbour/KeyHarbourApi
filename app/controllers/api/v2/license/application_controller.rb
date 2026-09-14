class Api::V2::License::ApplicationController < Api::V2::ApplicationController
  private
  
  def organization
    if @organization.nil?
      render json: { message: 'This token do not allow you to access the organization define by this UUID or the organization is not existing' }, status: 404
    end
    @organization
  end

  def validate_scopes
    unless @environment.nil?
      render json: { message: 'Invalid or outdated token. Unauthorized' }, status: 401 
    end
    logger.debug "Token scopes: #{@token.scopable}".yellow
    @organization = @token.scopable
    @service_name = "License"
    @serviceable = @organization
  end
end