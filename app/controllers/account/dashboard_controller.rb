class Account::DashboardController < ApplicationController
  include AccountController

  before_action :load_location

  def index
    @user = UserDecorator.decorate(current_user)
    @dashboard_announce = AnnounceDecorator.decorate(Announce.current.active.for_dashboard.select { |announce| (announce.group.present? && announce.group.users.include?(current_user)) || announce.group.blank? }.last)
  end

  private
  def load_location
    if params[:location].present?
      @location = params[:location]
    else
      @location = current_user.planning_location
    end
  end
end
