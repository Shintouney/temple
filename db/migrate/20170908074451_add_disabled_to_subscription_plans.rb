class AddDisabledToSubscriptionPlans < ActiveRecord::Migration
  def change
    add_column :subscription_plans, :disabled, :boolean, null: false, default: false
  end
end
