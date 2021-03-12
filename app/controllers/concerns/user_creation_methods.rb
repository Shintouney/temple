module UserCreationMethods
  extend ActiveSupport::Concern

  private

  def credit_card_params
    if params.key?(:user)
      params.
        require(:user).require(:credit_card).permit(
          :first_name, :last_name, :number, :month, :year, :brand, :verification_value
        )
    else
      {}
    end
  end

  def user_params
    if params.key?(:user)
      params.
        require(:user).
        dup.
        tap { |user_params| user_params.delete(:credit_card) }.
        permit(*User::CREATION_ATTRIBUTES, :billing_name, :billing_address)
    else
      {}
    end
  end

  def build_credit_card
    @credit_card = ActiveMerchant::Billing::CreditCard.new(credit_card_params)
  end

  def build_user
    if current_user.present? && current_user.user? && !current_user.active?
      @user = current_user
    else
      @user = User.new(user_params)
    end
  end

  def add_sponsor_to_user
    return true if params[:sponsor_email].blank?

    @sponsor_email = params[:sponsor_email].strip.downcase
    return true if @sponsor_email.blank?

    @sponsor = User.where(email: @sponsor_email).first

    return false unless @sponsor.present?

    @user.sponsor = @sponsor
    true
  end

  def blank_credit_card_params
    return if @credit_card.nil?
    @credit_card.number = nil
    @credit_card.verification_value = nil
  end
end
