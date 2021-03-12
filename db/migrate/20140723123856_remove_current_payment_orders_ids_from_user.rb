class RemoveCurrentPaymentOrdersIdsFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :current_payment_orders_ids, :string
  end
end
