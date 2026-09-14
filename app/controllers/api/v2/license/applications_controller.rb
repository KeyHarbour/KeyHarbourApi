class Api::V2::License::ApplicationsController < Api::V2::License::ApplicationController
  before_action :set_application, only: [ :show, :update, :destroy ]
  before_action :log_api_query

  def index
    logger.debug organization.apps_json
    logger.debug "Organization UUID: #{params[:organization_uuid]}".red
    render json: organization.apps_json, status: :ok
  end

  def show
    if @application.nil?
      render json: { message: 'This token do not allow you to access the application define by this UUID or the application is not existing' }, status: 404
      return
    end
    render json: 
      {
        name: @application.name,
        short_name: @application.short_name,
        owner: @application.owner,
        renewal_date: @application.renewal_date,
        vendor: @application.vendor,
        tier: @application.tier,
        seats: @application.seats,
        status: @application.status
      }, status: :ok
  end

  def create
    @application = organization.applications.new(item_params)
    if @application.save
      render json: { status: "created", uuid: @application.uuid }, status: :created
    else
      render json: { status: "unprocessable_entity" }, status: :unprocessable_entity
    end
  end

  def update
    if @application.update(item_params)
      render json: { status: "updated" }, status: :accepted
    else
      render json: { status: "Cannot update" }, status: :unprocessable_entity
    end
  end

  def destroy
    @application.destroy!
    head :no_content

    # render json: { status: "deleted" }, status: :no_content
  end

  private

  def item_params
    params.expect(application: [ :name, :short_name, :owner, :renewal_date, :vendor, :tier, :seats, :status, :unit_cost ])
  end

  def set_application
    return unless params[:uuid].present?
    
    @application = organization.applications.find_by(uuid: params[:uuid])

    if @application.nil?
      render json: { message: 'This token do not allow you to access the application define by this UUID or the application is not existing' }, status: 404
    end
  end
end