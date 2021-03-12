class AddCreditNoteRefOnExistingRefundedInvoices < ActiveRecord::Migration
  def change
    Invoice.with_state(:refunded).each do |invoice|
      if invoice.credit_note_ref.blank?
        refunded_invoices = Invoice.with_state(:refunded).where("invoices.credit_note_ref IS NOT NULL")
        invoice.credit_note_ref = refunded_invoices.present? ? refunded_invoices.sort{|a, b| a.credit_note_ref <=> b.credit_note_ref}.last.credit_note_ref + 1 : 1
        invoice.save
      end
    end
  end
end
