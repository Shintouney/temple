class AddCurrentPeriodInvoiceIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :current_period_invoice_id, :integer, references: :invoices
  end
end
