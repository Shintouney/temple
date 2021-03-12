class Admin::UsersController < ApplicationController
  include AdminController
  include UserCreationMethods

  before_action :load_user, only: [:show, :edit, :update, :update_origin_location, :force_access_to_planning, :forbid_access_to_planning, :change_payment_mode]

  before_action :build_user, only: [:new, :create]
  before_action :load_subscription_plan, only: [:create]

  def active
    @users = User.with_role(:user).includes(:subscriptions).references(:subscriptions).active

    respond_to do |format|
      format.html
      format.csv do
        export = Export.create!(export_type: "user", subtype: "active")
        @filename = I18n.t("admin.users.active.csv_filename", date: Date.today.to_formatted_s(:db))
        csv_string = CSVExporter::Users.new(export).execute
        send_csv(csv_string)
      end
      format.json { render json: DataTables::ActiveUser.new(view_context, @users).as_json }
    end
  end

  def inactive
    @users = User.with_role(:user).inactive

    respond_to do |format|
      format.html
      format.csv do
        export = Export.create!(export_type: "user", subtype: "inactive")
        @filename = I18n.t("admin.users.inactive.csv_filename", date: Date.today.to_formatted_s(:db))
        csv_string = CSVExporter::Users.new(export).execute
        send_csv(csv_string)
      end
      format.json { render json: DataTables::InactiveUser.new(view_context, @users).as_json }
    end
  end

  def red_list
    @users = User.red_list
  end

  def temporarily_suspended_users
    @users = User.includes(:subscriptions).where("subscriptions.state = ?", "temporarily_suspended").references(:subscriptions)

    respond_to do |format|
      format.html

      format.json { render json: DataTables::ActiveUser.new(view_context, @users).as_json }
    end
  end

  def show
    flash[:alert] = t('.no_payment_means') unless @user.has_payment_means?
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: t_action_flash(:notice)
    else
      flash.now[:alert] = t_action_flash(:alert)
      render action: 'edit'
    end
  end

  def new
  end

  def create
    @subscribe_user = User::Subscribe.new(@user, @subscription_plan, nil)
    @subscribe_user_action = nil

    if @user.valid? &&
        add_sponsor_to_user &&
        (@subscribe_user_action = @subscribe_user.execute)
      redirect_to edit_admin_user_credit_card_path(@user), notice: t_action_flash(:notice)
    else
      set_create_alert_error
      blank_credit_card_params
      render action: :new
    end
  end

  def force_access_to_planning
    @user.update_access_to_planning!(params[:state])
    respond_to do |format|
      format.html do
        flash[:alert] = t('.no_payment_means') unless @user.has_payment_means?
        render :show
      end
      format.json { render json: user_access_json }
    end
  end

  def forbid_access_to_planning
    @user.update_attributes!(forbid_access_to_planning: params[:state])
    render json: user_access_json
  end

  def change_payment_mode
    payment_mode = params['payment_mode'].eql?('true') ? 'cb' : 'sepa'
    if @user.update_attributes(payment_mode: payment_mode)
      render json: { status: 200 }
    else
      render json: { status: 400, errors: @user.errors.full_messages.join(', ') }
    end
  end

  def update_origin_location
    if params[:origin_location] == 'moliere'
      @user.subscriptions.last.update_attribute(:origin_location, 'moliere')
    elsif params[:origin_location] == 'maillot'
      @user.subscriptions.last.update_attribute(:origin_location, 'maillot')
    else
      @user.subscriptions.last.update_attribute(:origin_location, 'amelot')
    end
    redirect_to admin_user_path(@user), notice: t_action_flash(:notice)
  end

  private

  def user_access_json
    { status: 200, force: @user.force_access_to_planning, forbid: @user.forbid_access_to_planning }
  end

  def load_user
    @user = UserDecorator.decorate(User.with_role(:user).find(params[:id]))
  end

  def load_subscription_plan
    @subscription_plan = SubscriptionPlan.find(params[:subscription_plan_id])
  end

  def set_create_alert_error
    alert_flash_key = if (@sponsor_email.present? && @sponsor.blank?)
      :alert_sponsor_email_invalid
    elsif (@user.errors.none? && !@credit_card.valid?)
      :alert_invalid_credit_card
    elsif !@subscribe_user_action.nil?
      :alert_payment_failed
    else
      :alert_invalid_user
    end

    flash.now[:alert] = t(alert_flash_key, scope: 'flash.subscription.payments.create')
  end
end
