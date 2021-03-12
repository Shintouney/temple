class UnsubscribeRequestsController < ApplicationController

  layout 'login'

  def new
    @unsubscribe_request = UnsubscribeRequest.new
  end

  def create
    @unsubscribe_request = UnsubscribeRequest.new(unsubscribe_request_params)

    if @unsubscribe_request.save
      AdminMailer.unsubscribe_request_notification(@unsubscribe_request.id).deliver_later
      redirect_to unsubscribe_request_path(@unsubscribe_request), notice: t('.notice')
    else
      render action: 'new'
    end
  end

  def show
  end

  private
  def unsubscribe_request_params
    params.require(:unsubscribe_request).permit(:firstname,
                                      :lastname,
                                      :phone,
                                      :email,
                                      :desired_date,
                                      :health_reason,
                                      :moving_reason,
                                      :other_reason)
  end
end
