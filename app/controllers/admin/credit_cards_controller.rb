class Admin::CreditCardsController < ApplicationController
  include AdminController

  before_action :load_user
  before_action :load_current_credit_card, only: [:edit, :update]
  before_action :build_credit_card, only: [:edit, :update]

  def edit
    @mandate = @user.mandates.last
    if @mandate.present?
      begin
        @mandate.refresh
      rescue Slimpay::Error => e
        flash.now[:alert] = t('.cannot_refresh_mandate', reason: e.to_s)
        # flash.now[:alert] += t('.uri_not_found') if e.message[:code].eql?(404)
      end
    end
  end

  def update
    if @credit_card.valid? && CreditCard::Create.new(@user, @credit_card).execute
      redirect_to edit_admin_user_credit_card_path(@user), notice: t_action_flash(:notice)
    else
      flash.now[:alert] = "#{t_action_flash(:alert)} (#{@credit_card.errors.full_messages.to_sentence})"
      render action: :edit
    end
  end

  private

  def credit_card_params
    if params.key?(:credit_card)
      params.require(:credit_card).permit(:first_name, :last_name, :number, :month,
                                          :year, :brand, :verification_value)
    else
      {}
    end
  end

  def load_current_credit_card
    @current_credit_card = @user.current_credit_card.decorate unless @user.current_credit_card.nil?
  end

  def build_credit_card
    @credit_card = ActiveMerchant::Billing::CreditCard.new(credit_card_params)
  end

  def load_user
    @user = User.find(params[:user_id]).decorate
  end
end
