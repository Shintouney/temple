class AddInvoiceIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :invoice_id, :integer
  end
end
