class Data
  class CheckInvoice

    def initialize()
      @invoices = Invoice.where("next_payment_at > ?", Date.today)
    end

    def call
      deferred_invoice
      get_last_suspension_date
      check_if_payment_delay
    end

    private

    def check_if_payment_delay
      @invoices_impacted.each do |invoice|
        unless invoice.user.current_subscription.nil?
          date = Date.new(invoice.next_payment_at.year, invoice.next_payment_at.month, invoice.user.current_subscription.created_at.day)
          puts invoice.created_at
          puts invoice.next_payment_at

          #invoice.next_payment_at = date
          #invoice.save
        end
      end
    end

    def get_last_suspension_date
      @invoices_impacted = []
      @date = Date.new(2020, 06, 21)
      @invoices_deferred.each do |invoice|
        if invoice.user&.current_subscription&.restart_date == @date
          @invoices_impacted << invoice
        end
      end
    end

    def deferred_invoice
      @invoices_deferred = []
      @invoices.each do |invoice|
        if invoice.deferred?
          @invoices_deferred << invoice
        end
      end
    end
  end
end
