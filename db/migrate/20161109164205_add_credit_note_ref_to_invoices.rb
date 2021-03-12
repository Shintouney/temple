class AddCreditNoteRefToInvoices < ActiveRecord::Migration
  def change
  	add_column :invoices, :credit_note_ref, :integer
  end
end
