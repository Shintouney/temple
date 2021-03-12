class CreateOrdersPayments < ActiveRecord::Migration
  def change
    create_table :orders_payments do |t|
      t.references :payment
      t.references :order
    end
  end
end
