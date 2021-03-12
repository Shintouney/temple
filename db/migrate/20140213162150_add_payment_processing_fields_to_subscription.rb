class AddPaymentProcessingFieldsToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :current_payment_orders_ids, :string
    add_column :subscriptions, :payment_retries, :integer, default: 0
  end
end
