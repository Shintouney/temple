class AddLocationsOnSubsriptionPlans < ActiveRecord::Migration
  def change
    add_column :subscription_plans, :locations, :string
    add_column :subscriptions, :locations, :string

    SubscriptionPlan.all.each { |subcription_plan| subcription_plan.update_attribute(:locations, ['moliere']) }
    Subscription.all.each { |subcription| subcription.update_attribute(:locations, ['moliere']) }
  end
end
