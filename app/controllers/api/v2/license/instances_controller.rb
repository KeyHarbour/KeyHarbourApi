class Api::V2::License::InstancesController < Api::V2::License::ApplicationController
  before_action :set_application, except: [ :show, :update, :destroy ]  
  before_action :set_instance, only: [ :show, :update, :destroy ]
  before_action :log_api_query

  def index
    render json: @application.app_instances.pluck(:uuid, :name).map { |uuid, name| { uuid: uuid, name: name } }, status: :ok
  end

  def create
    @instance = @application.app_instances.new(item_params)
    if @instance.save
      render json: { status: "created", uuid: @instance.uuid }, status: :created
    else
      logger.debug @instance.errors.full_messages
      render json: { status: "unprocessable_entity" }, status: :unprocessable_entity
    end
  end

  def update
    if @instance.update(item_params)
      render json: { status: "updated" }, status: :accepted
    else
      render json: { status: "Cannot update" }, status: :unprocessable_entity
    end
  end

  def show
    if @instance.nil?
      render json: { message: 'This token do not allow you to access the instance define by this UUID or the instance is not existing' }, status: 404
      return
    end
    render json: 
      {
        name: @instance.name,
        short_name: @instance.short_name,
        owner: @instance.owner,
        renewal_date: @instance.renewal_date,
        seats: @instance.seats,
        status: @instance.status
      }, status: :ok
  end

  def destroy
    @instance.destroy!
    head :no_content
  end

  private

  def item_params
    params.expect(instance: [ :name, :short_name, :owner, :renewal_date, :seats, :status, :unit_cost ])
  end

  def set_instance
    return unless params[:uuid].present?
    if @application.nil?
      @instance = License::Instance.find_by(uuid: params[:uuid])
    else
      @instance = @application.instances.find_by(uuid: params[:uuid])
    end

    if @instance.nil?
      render json: { message: 'This token do not allow you to access the instance define by this UUID or the instance is not existing' }, status: 404
    end
  end

  def set_application
    return unless params[:application_uuid].present?
    
    @application = organization.applications.find_by(uuid: params[:application_uuid])

    if @application.nil?
      render json: { message: 'This token do not allow you to access the application define by this UUID or the application is not existing' }, status: 404
    end
  end
end