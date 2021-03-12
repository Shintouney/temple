class Account::InvoicesController < ApplicationController
  include AccountController

  before_action :load_invoice, only: [:show, :credit_note]

  def index
    @pagy, @user_invoices = pagy(current_user.invoices.with_state([:paid, :refunded]).order('created_at DESC'))
    @user_invoices = InvoiceDecorator.decorate_collection(@user_invoices)
  end

  def credit_note
    respond_to do |format|
      format.pdf do
        render pdf: "Avoir_#{@invoice.pdf_file_name}",
                template: 'account/invoices/credit_note'
      end
    end
  end

  def show
    respond_to do |format|
      format.pdf do
        render pdf: @invoice.pdf_file_name
      end
    end
  end

  private

  def load_invoice
    @invoice = InvoiceDecorator.decorate(current_user.invoices.with_state([:paid, :refunded]).find(params[:id]))
  end
end
