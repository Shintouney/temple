class MoveCurrentPaymentOrderidsAndPaymentRetriesToUser < ActiveRecord::Migration
  def change
    remove_column :subscriptions, :current_payment_orders_ids, :string
    remove_column :subscriptions, :payment_retries, :integer

    add_column :users, :current_payment_orders_ids, :string
  end
end
