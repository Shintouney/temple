class AddIndexStateToInvoices < ActiveRecord::Migration
  def change
    add_index :invoices, :state
  end
end
