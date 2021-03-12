class Account::NotificationsController < ApplicationController
  def create
    response = false
    if params[:notification].present?
      params[:notification].merge!(user_id: current_user.id)
      @notification = Notification.new(notification_params)
      response = @notification.save
      flash[:notice] = t_action_flash(:notice)
    end
    render json: { success: response }
  end

  def destroy
    @notification = Notification.where(sourceable_id: params[:id], sourceable_type: params[:type]).first
    response = @notification.present? ? @notification.destroy : false
    flash[:notice] = t_action_flash(:notice)
    render json: { success: response.present? }
  end

  private

  def notification_params
    if params.key?(:notification)
      params.require(:notification).
              permit(:user_id,
                      :sourceable_id,
                      :sourceable_type)
    end
  end
end
