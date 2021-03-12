class AddDefaultsStateValues < ActiveRecord::Migration
  def change
    change_column :payments, :state, :string, default: "transaction_pending", null: false
    change_column :subscriptions, :state, :string, default: "pending", null: false
    change_column :invoices, :state, :string, default: "open", null: false
  end
end
