class Admin::GroupsController < ApplicationController
  include AdminController

  before_action :load_group, only: [:edit, :update, :destroy, :export]
  before_action :build_group, only: [:new, :create]

  def index
    @groups = Group.all.order('created_at DESC')
  end

  def new
    @users = []
  end

  def create
    @users = User::Search.new(group_params).execute
    if @group.save
      redirect_to edit_admin_group_path(@group), notice: t_action_flash(:notice)
    else
      flash.now[:alert] = t_action_flash(:alert)
      render action: :new
    end
  end

  def edit
    @users = @group.users
  end

  def update
    @users = User::Search.new(group_params).execute
    @group.users = @users

    if @group.update(group_params)
      redirect_to edit_admin_group_path(@group), notice: t_action_flash(:notice)
    else
      flash.now[:alert] = t_action_flash(:alert)
      render action: 'edit'
    end
  end

  def destroy
    @group.destroy
    redirect_to admin_groups_path, notice: t_action_flash(:notice)
  end

  def export
    @users = @group.users

    respond_to do |format|
      format.csv do
        @filename = I18n.t("admin.groups.export.csv_filename", name: @group.name, date: Date.today.to_formatted_s(:db))
        csv_string = CSVExporter::Users.new(@users).execute
        send_csv(csv_string)
      end
    end
  end

  private

  def load_group
    @group = Group.find(params[:id])
  end

  def build_group
    @group = Group.new(group_params)
    @group.user_ids = params["group"]["user_ids"].tr('[]', '').split(",").map(&:to_i) if params["group"].present?
  end

  def group_params
    if params.key?(:group)
      params.require(:group).permit(:name,
                                    { :filter_between_age => [] },
                                    { :filter_gender => [] },
                                    { :filter_postal_code => [] },
                                    { :filter_with_subscription => [] },
                                    { :filter_created_since => [] },
                                    { :filter_usual_room => [] },
                                    { :filter_usual_activity => [] },
                                    { :filter_frequencies => [] },
                                    { :filter_last_booking_dates => [] },
                                    { :filter_last_visite_dates => [] },
                                    { :filter_last_article => [] }).reject { |g| g.first.blank? }
    else
      {}
    end
  end
end
