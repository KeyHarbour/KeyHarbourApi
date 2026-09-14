class Api::V2::License::TeamMembersController < Api::V2::License::ApplicationController
  before_action :set_team_member, only: [ :show, :update, :destroy ]
  before_action :log_api_query

  def index
    render json: @organization.app_team_members.map { |member| { uuid: member.uuid, manager_uuid: member.manager_uuid } }, status: :ok
  end

  def create
    manager = @organization.app_team_members.first_or_create(uuid: item_params[:manager_uuid]) if item_params[:manager_uuid].present?
    @team_member = @organization.app_team_members.new(uuid: item_params[:uuid], manager: manager)
    if @team_member.save
      render json: { status: "created", uuid: @team_member.uuid }, status: :created
    else
      logger.debug @team_member.errors.full_messages
      render json: { status: "unprocessable_entity" }, status: :unprocessable_entity
    end
  end

  def update
    if @team_member.update(item_params)
      render json: { status: "updated" }, status: :accepted
    else
      render json: { status: "Cannot update" }, status: :unprocessable_entity
    end
  end

  def show
    if @team_member.nil?
      render json: { message: 'This token do not allow you to access the team member define by this UUID or the team member is not existing' }, status: 404
      return
    end
    render json: 
      {
        uuid: @team_member.uuid,
        manager_uuid: @team_member.manager_uuid
      }, status: :ok
  end

  def destroy
    @team_member.destroy!
    head :no_content
  end

  private

  def item_params
    params.expect(team_member: [ :uuid, :manager_uuid ])
  end

  def set_team_member
    return unless params[:uuid].present?

    @team_member = @organization.app_team_members.find_by(uuid: params[:uuid])

    if @team_member.nil?
      render json: { message: 'This token do not allow you to access the team member define by this UUID or the team member is not existing' }, status: 404
    end
  end
end