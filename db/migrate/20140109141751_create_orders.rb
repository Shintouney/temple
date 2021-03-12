class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.timestamps

      t.decimal :total_price_ati, precision: 8, scale: 2, default: 0, null: false
    end
  end
end
