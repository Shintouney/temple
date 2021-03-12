module Slimpay
  class AcceptSepaPaymentsJob < ActiveJob::Base
    queue_as :default

    # Mark unchanged sepa_payments as paid
    def perform
      ::Payment.with_state(:waiting_slimpay_confirmation).where('payments.created_at < ?', ::Date.today.advance(days: -6)).each do |payment|
        payment.accept!
        payment.invoices.first.accept_payment!
      end
    end
  end
end