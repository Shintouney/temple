class UpdateSubscriptionPlansDurationFields < ActiveRecord::Migration
  def change
    remove_column :subscription_plans, :periodicity
    add_column :subscription_plans, :periodicity, :integer
    remove_column :subscription_plans, :duration
    add_column :subscription_plans, :max_duration, :integer
    add_column :subscription_plans, :next_subscription_plan_id, :integer, references: :subscription_plans
  end
end
