class Account::UsersController < ApplicationController
  include AccountController

  before_action :load_user

  def show
  end

  def update
    if @user.update_attributes(user_params)
      redirect_to account_user_path, notice: t_action_flash(:notice)
    else
      flash.now[:alert] = t_action_flash(:alert)
      render action: :show
    end
  end

  private

  def user_params
    if params.key?(:user)
      params.require(:user).permit(:street1, :street2, :postal_code, :city, :country_code, :phone, :birthdate, :billing_address,
                                   :facebook_url, :linkedin_url, :receive_mail_ical, :billing_name, :receive_booking_confirmation)
    end
  end

  def load_user
    @user = current_user
  end
end
