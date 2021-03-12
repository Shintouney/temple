class Invoices::ChargesPendingDeferredJob < ActiveJob::Base
  queue_as :default

  def perform
    ::Invoice.pending.due.pluck(:id).each do |invoice_id|
      ::Invoices::ChargePendingDeferredJob.perform_later(invoice_id)
    end
  end
end
