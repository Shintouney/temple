class AddExpireAtToSubscriptionPlan < ActiveRecord::Migration
  def change
    add_column :subscription_plans, :expire_at, :datetime
  end
end
