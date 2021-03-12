namespace :invoices do
  task charge_pending_deferred: :environment do
    Raven.capture do
      invoice_id = nil
      begin
        Invoice.pending.due.each do |invoice|
          invoice_id = invoice.id
          Invoice::Deferred::Charge.new(invoice).execute
        end
      rescue
        AdminMailer.invoice_charge_error([invoice_id]).deliver_later
        raise
      end
    end
  end
end
