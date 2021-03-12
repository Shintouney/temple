class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.timestamps

      t.references :order, null: false
      t.string :product_type, null: false
      t.references :product, null: false, polymorphic: true
      t.string :product_name, null: false
      t.decimal :product_price, precision: 8, scale: 2, null: false
    end
  end
end
