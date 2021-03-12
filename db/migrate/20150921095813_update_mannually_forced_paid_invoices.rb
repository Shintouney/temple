class UpdateMannuallyForcedPaidInvoices < ActiveRecord::Migration
  def change
    invoices_with_pb = Invoice.with_state("paid").select {|i| i.payments.map {|p| p.state}.uniq.count == 1 && i.payments.map {|p| p.state}.uniq.include?('declined')}
    invoices_with_pb.each do |invoice|
      invoice.update_attribute :manual_force_paid, true
      invoice.user.authorize_card_access
    end
  end
end
