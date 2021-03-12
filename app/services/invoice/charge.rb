class Invoice
  class Charge

    attr_reader :invoice, :payment, :user

    def initialize(invoice)
      @invoice = invoice
      raise ArgumentError.new("invoice cannot be nil") unless @invoice.present?

      @user = @invoice.user
      raise ArgumentError.new("invoice ##{@invoice.try(:id)} is not related to a user") unless @user.present?
      raise ArgumentError.new("invoice ##{@invoice.try(:id)} is not chargeable") unless @invoice.chargeable?

      build_payment
    end

    def execute
      if User::TEMPLE_GHOSTS.include?(@user.email) || invoice.total_price_ati.to_i == 0
        process_payment_for_ghosts
      elsif Rails.env.staging?     # Those two lines are monkey patch and need to be patch (https://github.com/activemerchant/active_merchant/pull/3395)
        process_payment_for_ghosts # An recent update make sandbox of ActiveMerchant broken so the gem need to be updated to his latest version
      else
        process_payment
      end

      invoice.paid? || invoice.sepa_waiting?
    end

    private

    def process_payment
      result = Payment::Processor.new(payment).execute
      return unless result
      if @user.payment_mode.sepa? && @user.mandates.ready.last.present?
        invoice.mark_as_sepa!
      elsif @user.payment_mode.cb? && @user.current_credit_card.present?
        invoice.accept_payment!
      end
    end

    def process_payment_for_ghosts
      @payment.compute_price
      @payment.save!
      @payment.accept!
      invoice.accept_payment!
    end

    def build_payment
      @payment = Payment.new(invoices: [invoice], user: user, credit_card: user.current_credit_card)
    end
  end
end
