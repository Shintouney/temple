class Admin::SubscriptionPlansController < ApplicationController
  include AdminController

  before_action :load_subscription_plan, only: [:edit, :update, :destroy, :disable]
  before_action :build_subscription_plan, only: [:new, :create]

  def index
    @subscription_plans = SubscriptionPlanDecorator.decorate_collection(SubscriptionPlan.where(disabled: false).includes(:subscriptions).order('position ASC'))
  end

  def new
  end

  def create
    if @subscription_plan.save
      redirect_to admin_subscription_plans_path, notice: t_action_flash(:notice)
    else
      render action: :new
    end
  end

  def edit
    flash.now[:alert] = t_action_flash(:edit_limited) if @subscription_plan.edit_restricted?
  end

  def update
    if @subscription_plan.update(subscription_plan_params)
      redirect_to admin_subscription_plans_path, notice: t_action_flash(:notice)
    else
      flash.now[:alert] = t_action_flash(:alert)
      render action: :edit
    end
  end

  def update_positions
    positions = params[:positions]

    SubscriptionPlan.order('id ASC').each do |subscription_plan|
      position = positions.index(subscription_plan.id.to_s) + 1
      subscription_plan.set_list_position(position)
    end

    render json: SubscriptionPlan.order('position ASC').ids
  end

  def destroy
    if @subscription_plan.destroy
      redirect_to admin_subscription_plans_path, notice: t_action_flash(:notice)
    else
      redirect_to admin_subscription_plans_path, alert: t_action_flash(:alert)
    end
  end

  def disable
    if @subscription_plan.update_attributes(disabled: true, displayable: false)
      redirect_to admin_subscription_plans_path, notice: t_action_flash(:notice)
    else
      redirect_to admin_subscription_plans_path, alert: t_action_flash(:alert)
    end
  end

  private

  def load_subscription_plan
    @subscription_plan = SubscriptionPlan.includes(:subscriptions).find(params[:id]).decorate
  end

  def build_subscription_plan
    @subscription_plan = SubscriptionPlan.new(formated_subscription_plan_params).decorate
  end

  def formated_subscription_plan_params
    subscription_plan_params.merge(locations: subscription_plan_params[:locations].try{ |l| l.reject(&:empty?).map(&:downcase) })
  end

  def subscription_plan_params
    if params.key?(:subscription_plan)
      params.require(:subscription_plan).permit(:name,
                                                :price_ati,
                                                :price_te,
                                                :taxes_rate,
                                                :description,
                                                :commitment_period,
                                                :code,
                                                :discount_period,
                                                :discounted_price_te,
                                                :discounted_price_ati,
                                                :sponsorship_price_te,
                                                :sponsorship_price_ati,
                                                :expire_at,
                                                :displayable,
                                                :favorite,
                                                { locations: [] })
    else
      {}
    end
  end
end
