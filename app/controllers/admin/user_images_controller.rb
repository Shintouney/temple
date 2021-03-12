class Admin::UserImagesController < ApplicationController
  include AdminController

  before_action :load_user
  before_action :load_user_image, only: [:make_profile_image, :destroy]
  before_action :build_user_image, only: [:create]

  def index
    @user = UserDecorator.decorate(@user)
  end

  def create
    if @user_image.save
      flash[:notice] = t_action_flash(:notice)
    else
      flash[:alert] = t_action_flash(:alert)
    end

    redirect_to admin_user_user_images_path(@user)
  end

  def make_profile_image
    @user.update_attributes profile_user_image: @user_image

    redirect_to admin_user_user_images_path(@user), notice: t_action_flash(:notice)
  end

  def destroy
    @user_image.destroy

    redirect_to admin_user_user_images_path(@user), notice: t_action_flash(:notice)
  end

  private

  def load_user
    @user = User.find(params[:user_id])
  end

  def load_user_image
    @user_image = @user.user_images.find(params[:id])
  end

  def user_image_params
    params.key?(:user_image) ? params.require(:user_image).permit(:image) : {}
  end

  def build_user_image
    @user_image = @user.user_images.build(user_image_params)
  end
end
