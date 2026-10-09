class Api::V2::License::ApplicationController < Api::V2::ApplicationController
  private

  def authenticate_token!
    logger.debug "----".blue * 50
    @token = TokenAccount.check(bearer_token)

    if @token.nil?
      render json: { message: 'Invalid or outdated token. Unauthorized' }, status: 401 
    else
      @account = @token.account
      @serviceable = @account
      @service_name = "License"
    end
  end
  
  def organization
    if @organization.nil?
      render json: { message: 'This token do not allow you to access the account define by this UUID or the account is not existing' }, status: 404
    end
    @organization
  end

  def check_application(uuid)    
    @application = @account.applications.find_by(uuid: uuid)
    if @application.nil?
      render json: { message: 'This token do not allow you to access the application define by this UUID or the application is not existing' }, status: 404
    end
  end

  def check_instance(uuid)  
    if @application.nil?  
      @instance = License::Instance.find_by(uuid: uuid)
    else
      @instance = @application.instances.find_by(uuid: uuid)
    end
    if @instance.nil?
      render json: { message: 'This token do not allow you to access the instance define by this UUID or the instance is not existing' }, status: 404
    end
  end

  def set_application
    return unless params[:uuid].present?

    check_application(params[:uuid])
  end
end