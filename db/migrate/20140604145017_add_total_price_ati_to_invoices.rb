class AddTotalPriceAtiToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :total_price_ati, :decimal, precision: 8, scale: 2, default: 0.0, null: false
  end
end
