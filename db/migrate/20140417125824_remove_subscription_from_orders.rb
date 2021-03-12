class RemoveSubscriptionFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :subscription_id
  end
end
