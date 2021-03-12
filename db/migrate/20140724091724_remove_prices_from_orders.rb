class RemovePricesFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :total_price_te, :decimal, precision: 8, scale: 2, default: 0.0, null: false
    remove_column :orders, :total_price_ati, :decimal, precision: 8, scale: 2, default: 0.0, null: false
  end
end
