class Admin::SuspendedSubscriptionSchedulesController < ApplicationController
  include AdminController

  before_action :load_suspended_subscritpion_schedule, only: [:destroy]

  def create
    @suspended_subscritpion_schedule = SuspendedSubscriptionSchedule.new(suspended_subscription_schedule_params)
    if @suspended_subscritpion_schedule.save
      redirect_to edit_admin_user_subscription_path, notice: t_action_flash(:notice)
    else
      redirect_to edit_admin_user_subscription_path, alert: t_action_flash(:alert)
    end
  end

  def destroy
    @suspended_subscritpion_schedule.destroy
    redirect_to edit_admin_user_subscription_path, notice: t_action_flash(:notice)
  end

  private

  def load_suspended_subscritpion_schedule
    @suspended_subscritpion_schedule = SuspendedSubscriptionSchedule.find(params[:id])
  end

  def suspended_subscription_schedule_params
    if params.key?(:suspended_subscription_schedule)
      params.require(:suspended_subscription_schedule).permit(:user_id, :scheduled_at, :subscription_restart_date)
    else
      {}
    end
  end
end
