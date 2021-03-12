class AddGracePeriodToSubscriptions < ActiveRecord::Migration
  def change
  	add_column :subscriptions, :grace_period_in_days, :integer
  end
end
