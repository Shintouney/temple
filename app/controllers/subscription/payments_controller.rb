class Subscription::PaymentsController < ApplicationController
  include UserCreationMethods

  before_action :redirect_logged_in_user, only: [:new, :create]
  before_action :load_subscription_plan
  before_action :build_credit_card, only: [:new, :create]
  before_action :build_user, only: [:new, :create]

  def new
  end

  def create
    @subscribe_user = User::Subscribe.new(@user, @subscription_plan.object, @credit_card)
    @subscribe_user_action = nil

    begin
      if @user.valid? &&
          terms_accepted? &&
          add_sponsor_to_user &&
          @credit_card.valid? &&
          (@subscribe_user_action = @subscribe_user.execute)
        auto_login(@user, true)
        register_login_time_to_db(@user, nil)
        redirect_to subscription_payment_path
      else
        set_create_alert_error
        blank_credit_card_params
        render action: :new
      end
    rescue SocketError => e
      set_create_alert_error
      blank_credit_card_params
      flash.now[:alert] += " : #{ e.message }"
      render action: :new
    end
  end

  def show
    return if logged_in?
    redirect_to new_subscription_payment_path
  end

  private

  def terms_accepted?
    params[:terms_accepted] == '1'
  end

  def load_subscription_plan
    if session[:subscription_plan_id]
      @subscription_plan = SubscriptionPlan.find(session[:subscription_plan_id]).decorate
    else
      redirect_to subscription_plans_path
    end
  end

  def set_create_alert_error
    alert_flash_key = if (@user.errors[:email].present? && User.exists?(email: @user.email))
      :alert_existing_account
    elsif !terms_accepted?
      :alert_terms_not_accepted
    elsif (@sponsor_email.present? && @sponsor.blank?)
      :alert_sponsor_email_invalid
    elsif (@user.errors.none? && !@credit_card.valid?)
      :alert_invalid_credit_card
    elsif !@subscribe_user_action.nil?
      :alert_payment_failed
    elsif !@user.valid?
      :alert_invalid_user
    else
      :alert_unknown_error
    end
    flash.now[:alert] = t_action_flash(alert_flash_key)
  end
end
