class SubscriptionPlansController < ApplicationController
  before_action :redirect_logged_in_user, except: [:embed]

  skip_before_action :verify_authenticity_token

  before_action :load_subscription_plans, only: [:index, :embed]
  before_action :load_subscription_plan, :build_subscription_plan_selection_validator, only: [:show, :buy]

  def index
  end

  def embed
    response.headers['Access-Control-Allow-Origin'] = '*'

    render layout: false
  end

  def show
  end

  def buy
    if @subscription_plan_selection_validator.valid?
      session[:subscription_plan_id] = @subscription_plan.id

      redirect_to new_subscription_payment_path
    else
      flash.now[:alert] = t_action_flash(:alert)
      render :show
    end
  end

  private

  def load_subscription_plans
    @subscription_plans = SubscriptionPlanDecorator.decorate_collection(SubscriptionPlan.
                                                                          not_expired.
                                                                          displayable.
                                                                          order('position ASC'))
  end

  def load_subscription_plan
    @subscription_plan = SubscriptionPlan.find(params[:id]).decorate
  end

  def build_subscription_plan_selection_validator
    @subscription_plan_selection_validator = SubscriptionPlanSelectionValidator.new(
                                               subscription_plan: @subscription_plan,
                                               code: params.fetch(:subscription_plan_selection_validator, {})[:code]
                                             )
  end
end
