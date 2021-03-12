class Admin::AdminUsersController < ApplicationController
  include AdminController

  before_action :load_user, only: [:edit, :update, :destroy]
  before_action :build_user, only: [:new, :create]

  def index
    @users = User.with_role(:admin)
  end

  def new
  end

  def create
    if @user.save
      ResamaniaApi::PushUserWorker.perform_async(@user.id)
      redirect_to admin_admin_users_path, notice: t_action_flash(:notice)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      ResamaniaApi::PushUserWorker.perform_async(@user.id)
      redirect_to admin_admin_users_path, notice: t_action_flash(:notice)
    else
      render :new
    end
  end

  def destroy
    ResamaniaApi::DeleteUserWorker.perform_async(@user.id)

    @user.destroy

    redirect_to admin_admin_users_path, notice: t_action_flash(:notice)
  end

  private

  def load_user
    @user = UserDecorator.decorate(User.with_role(:admin).find(params[:id]))
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
                    :password,
                    :password_confirmation,
                    :card_reference,
                    :location).
              merge(role: :admin)
    else
      {}
    end
  end
end
