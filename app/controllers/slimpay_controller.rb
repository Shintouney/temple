class SlimpayController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :ipn
  before_action :load_user, only: [:sepa, :destroy_pending_mandates]
  layout 'admin'

  # POST notification from the outside. Shall only be Slimpay
  def ipn
    head :bad_request and return if request.raw_post.blank? || request.raw_post['reference'].blank?
    raw_post = JSON.parse(request.raw_post)
    mandate = Mandate.find_by(slimpay_order_reference: raw_post['reference'])
    head :unprocessable_entity and return if mandate.nil?
    mandate.update_from_ipn(raw_post)
    head :ok
  end

  # POST from inside app. Creates a Slimpay Order and redirect to Slimpay's approval page.
  def sepa
    mandate = @user.mandates.last
    if mandate.present? && mandate.ready?
      redirect_to_for_user_or_admin and return
    end
    redirect_to mandate.slimpay_approval_url and return if mandate && mandate.waiting?
    mandate = Mandate.sign(@user)
    if mandate.present?
      redirect_to mandate.slimpay_approval_url
    else
      redirect_to_for_user_or_admin(true)
    end
  end

  def mandate_signature_return
    if current_user && current_user.role.user?
      mandate = current_user.mandates.last
      if mandate.present?
        begin
          mandate.refresh
          mandate.reload
          current_user.reload
        rescue Slimpay::Error => e
          flash.now[:alert] = t('.cannot_refresh_mandate', reason: e.to_s)
        end
      end
      render layout: 'account'
    end
  end

  # Remove mandate which are not signed yet, so the user can sign a new one
  def destroy_pending_mandates
    @user.mandates.where(slimpay_order_state: Mandate::SLIMPAY_ORDER_WAITING).first.try(:destroy)
    @user.update_attributes(payment_mode: 'cb')
    redirect_to :back
  end

  def destroy
    @mandate = Mandate.find(params[:id])
    @user = @mandate.user
    @mandate.update_column :marked_as_deleted, true
    @user.update_attributes(payment_mode: 'cb')
    redirect_to edit_admin_user_credit_card_path(@user), notice: t_action_flash(:notice)
  end

  protected
  def load_user
    @user = User.find(params[:user_id])
  end

  def redirect_to_for_user_or_admin(with_flash = false)
    if current_user.role.admin?
      redirect_to edit_admin_user_credit_card_path(@user), alert: with_flash ? t_action_flash(:alert) : nil
    else
      redirect_to account_payment_means_path, alert: with_flash ? t_action_flash(:alert) : nil
    end
  end
end
