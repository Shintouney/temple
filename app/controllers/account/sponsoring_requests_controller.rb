class Account::SponsoringRequestsController < ApplicationController
  include AccountController

  def new
    @sponsoring_request = SponsoringRequest.new
  end

  def create
    @sponsoring_request = SponsoringRequest.new(sponsoring_request)

    if @sponsoring_request.save
      AdminMailer.sponsoring_request_notification(@sponsoring_request.id).deliver_later
      redirect_to new_account_sponsoring_request_path, notice: t('.notice')
    else
      render action: 'new'
    end
  end

  private
  def sponsoring_request
    params.require(:sponsoring_request).permit(:firstname,
                                      :lastname,
                                      :phone,
                                      :email, :user_id)
  end
end
