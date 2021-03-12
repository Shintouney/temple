class PasswordsController < ApplicationController
  before_action :load_user_from_token, :build_user_password_updater, only: [:edit, :update]

  layout 'login'

  def create
    @reset_password_request = ResetPasswordRequest.new(params[:reset_password_request])

    if @reset_password_request.valid?
      @reset_password_request.user.deliver_reset_password_instructions!
      UserMailer.reset_password_email(@reset_password_request.user.id).deliver_later

      redirect_to login_path, notice: t_action_flash(:notice)
    else
      redirect_to new_password_path, alert: t_action_flash(:alert)
    end
  end

  def update
    if @user_password_updater.save
      auto_login(@user_password_updater.user, true)
      after_login!(@user_password_updater.user)

      redirect_to root_path, notice: t_action_flash(:notice)
    else
      flash.now[:alert] = t_action_flash(:alert)
      render action: :edit
    end
  end

  private

  def load_user_from_token
    @token = params[:token]
    @user = User.load_from_reset_password_token(@token)

    redirect_to(login_path, alert: t('flash.passwords.edit.alert')) unless @token.present? && @user.present?
  end

  def build_user_password_updater
    user_password_updater_params = params.fetch(:user_password_updater, {}).merge(user: @user)
    @user_password_updater = User::PasswordUpdater.new(user_password_updater_params)
  end
end
