class AddIndexEndAtToInvoices < ActiveRecord::Migration
  def change
    add_index :invoices, :end_at
  end
end
