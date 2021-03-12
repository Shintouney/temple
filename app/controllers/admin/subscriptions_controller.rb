class Admin::SubscriptionsController < ApplicationController
  include AdminController

  before_action :load_user
  before_action :check_subscription_plan_params
  before_action :load_subscription_plan, only: [:update]
  before_action :load_suspended_subscription_schedule, only: [:edit, :destroy]
  before_action :load_next_payment_at, only: [:edit, :update]

  def edit
  end

  def update
    @change_user_subscription_plan = User::ChangeSubscriptionPlan.new(@user.object, @subscription_plan)
    if @change_user_subscription_plan.execute
      redirect_to edit_admin_user_subscription_path(@user), notice: t_action_flash(:notice)
    else
      flash.now[:alert] = t_action_flash(:alert)
      render :edit
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      @suspended_subscription_schedule.try(:destroy)
      @user.subscriptions.with_state([:running, :temporarily_suspended]).each(&:cancel!)
    end
    redirect_to edit_admin_user_subscription_path, notice: t_action_flash(:notice)
  end

  def restart
    target_subscription = @user.subscriptions.with_state(:temporarily_suspended).first
    target_subscription.update_attributes!(restart_date: Date.today)
    redirect_to edit_admin_user_subscription_path, notice: t_action_flash(:notice)
  end

  private

  def load_next_payment_at
    @next_payment_at = @user.invoices.with_state(:open).try(:last).try(:next_payment_at)
  end

  def load_suspended_subscription_schedule
    @suspended_subscription_schedule = SuspendedSubscriptionSchedule.where(user_id: @user.id).first
  end

  def load_user
    @user = User.find(params[:user_id]).decorate
  end

  def load_subscription_plan
    @subscription_plan = SubscriptionPlan.find(subscription_plan_params)
  end

  def check_subscription_plan_params
    return if params[:subscription_plan].nil? || params[:subscription_plan][:id].present?
    flash.now[:alert] = t_action_flash(:alert)
    render :edit
  end

  def subscription_plan_params
    params.require(:subscription_plan).require(:id)
  end
end
