class Api::V2::License::LicenseesController < Api::V2::License::ApplicationController
  before_action :set_instance, except: [ :show, :update, :destroy ]  
  before_action :set_licensee, only: [ :show, :update, :destroy ]

  rescue_from ActionController::ParameterMissing do |exception|
    render json: { error: exception.message }, status: :unprocessable_entity # Code 422
  end

  def index
    render json: @instance.licensees.pluck(:uuid), status: :ok
  end

  def create
    @licensee = @instance.licensees.new(item_params)
    if @licensee.save
      render json: { status: "created", uuid: @licensee.uuid }, status: :created
    else
      logger.debug @licensee.errors.full_messages
      render json: { status: "unprocessable_entity" }, status: :unprocessable_entity
    end
  end

  def update
    if @licensee.update(item_params)
      render json: { status: "updated" }, status: :accepted
    else
      render json: { status: "Cannot update" }, status: :unprocessable_entity
    end
  end

  def show
    if @licensee.nil?
      render json: { message: 'This token do not allow you to access the licensee define by this UUID or the licensee is not existing' }, status: 404
      return
    end
    render json: 
      {
        uuid: @licensee.uuid,
        status: @licensee.status
      }, status: :ok
  end

  def destroy
    @licensee.destroy!
    head :no_content
  end

  private

  def item_params
    params.expect(licensee: [ :instance_id, :uuid, :status ])
  end

  def set_licensee
    return unless params[:uuid].present?

    if @instance.nil?
      @licensee = License::Licensee.find_by(uuid: params[:uuid])
    else
      @licensee = @instance.licensees.find_by(uuid: params[:uuid])
    end

    if @licensee.nil?
      render json: { message: 'This token do not allow you to access the licensee define by this UUID or the licensee is not existing' }, status: 404
    end
  end

  def set_instance
    return unless params[:instance_uuid].present?
    
    @instance = @organization.app_instances.find_by(uuid: params[:instance_uuid])

    if @instance.nil?
      render json: { message: 'This token do not allow you to access the instance define by this UUID or the instance is not existing' }, status: 404
    end
  end
end