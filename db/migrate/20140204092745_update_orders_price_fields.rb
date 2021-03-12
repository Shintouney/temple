class UpdateOrdersPriceFields < ActiveRecord::Migration
  def change
    add_column :orders, :total_price_te, :decimal, precision: 8, scale: 2, default: 0, null: false

    rename_column :order_items, :product_price, :product_price_ati
    add_column :order_items, :product_price_te, :decimal, precision: 8, scale: 2, null: false
    add_column :order_items, :product_taxes_rate, :decimal, precision: 5, scale: 2, null: false

    rename_column :subscription_plans, :price, :price_ati
    add_column :subscription_plans, :price_te, :decimal, precision: 8, scale: 2, null: false
    add_column :subscription_plans, :taxes_rate, :decimal, precision: 5, scale: 2, null: false
  end
end
