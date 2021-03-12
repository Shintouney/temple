class Admin::InvoicesController < ApplicationController
  include AdminController

  before_action :load_user
  before_action :load_invoice, only: [:show, :update, :payments, :credit_note]

  def index
    @pagy, @user_invoices = pagy(@user.user.invoices.order('end_at DESC'))
    @user_invoices = InvoiceDecorator.decorate_collection(@user_invoices)
  end

  def show
    respond_to do |format|
      format.pdf do
        render pdf: @invoice.pdf_file_name,
                template: 'account/invoices/show'
      end
    end
  end

  def credit_note
    respond_to do |format|
      format.pdf do
        render pdf: "Avoir_#{@invoice.pdf_file_name}",
                template: 'account/invoices/credit_note'
      end
    end
  end

  def update
    update_invoice_state(params['update'])

    redirect_to admin_user_invoices_path(@user), notice: t_action_flash(:notice)
  end

  def payments
  end

  private

  def update_invoice_state(event)
    if event == 'cancel'
      @invoice.cancel!
    elsif event == 'refund'
      @invoice.refund!
    elsif event == 'accept_payment'
      @invoice.update_attribute :manual_force_paid, true
      @invoice.accept_payment!
      @invoice.user.authorize_card_access unless @invoice.user.has_late_payments?
    end
  end

  def load_user
    @user = UserDecorator.decorate(User.find(params[:user_id]))
  end

  def load_invoice
    @invoice = InvoiceDecorator.decorate(@user.object.invoices.find(params[:id]))
  end
end
