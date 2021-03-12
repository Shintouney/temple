class Invoices::ChargePendingDeferredJob < ActiveJob::Base
  queue_as :default

  def perform(invoice_id)
    ::Raven.capture do
      begin
        invoice = Invoice.pending.due.find(invoice_id)
        ::Invoice::Deferred::Charge.new(invoice).execute
      rescue
        ::AdminMailer.invoice_charge_error([invoice_id]).deliver_later
        raise
      end
    end
  end
end
