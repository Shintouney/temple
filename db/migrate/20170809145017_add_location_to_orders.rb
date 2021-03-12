class AddLocationToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :location, :string

    Order.all.each { |order| order.update_attribute(:location, 'moliere') }
  end
end
