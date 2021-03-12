class Admin::StaffUsersController < ApplicationController
  include AdminController

  before_action :load_user, only: [:edit, :update, :destroy]
  before_action :build_user, only: [:new, :create]

  def index
    @users = User.with_role(:staff)
  end

  def new
  end

  def create
    if @user.save
      ResamaniaApi::PushUserWorker.perform_async(@user.id)
      redirect_to admin_staff_users_path, notice: t_action_flash(:notice)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      ResamaniaApi::PushUserWorker.perform_async(@user.id)
      redirect_to admin_staff_users_path, notice: t_action_flash(:notice)
    else
      render :new
    end
  end

  def destroy
    ResamaniaApi::DeleteUserWorker.perform_async(@user.id)

    @user.destroy

    redirect_to admin_staff_users_path, notice: t_action_flash(:notice)
  end

  private

  def load_user
    @user = UserDecorator.decorate(User.with_role(:staff).find(params[:id]))
  end

  def build_user
    @user = User.new(user_params)
  end

  def user_params
    if params.key?(:user)
      params.require(:user).
              permit(:email,
                    :firstname,
                    :lastname,
                    :card_reference,
                    :location,
                    :password,
                    :password_confirmation).
              merge(role: :staff)
    else
      {}
    end
  end
end
