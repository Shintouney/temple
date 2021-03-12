class AddPositionToSubscriptionPlans < ActiveRecord::Migration
  def change
    add_column :subscription_plans, :position, :integer
  end
end
