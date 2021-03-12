class Account::LessonsController < ApplicationController
  include AccountController

  before_action :load_location

  def index
    ##if current_user.present? && current_user.has_access_to_planning? && current_user.active? && current_user.is_not_temporarily_suspended?
    if current_user.present? && current_user.has_access_to_planning?
      @current_lesson = current_user.decorate.next_lesson_booking.try(:lesson)
    else
      redirect_to account_root_path, alert: t_action_flash(:alert)
    end
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
