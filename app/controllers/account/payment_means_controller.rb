class Account::PaymentMeansController < ApplicationController
  include AccountController

  layout 'account'

  def index
    @mandate = current_user.mandates.last
  end
end
