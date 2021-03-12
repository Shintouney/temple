class AddColumnSubscriptionRestartAtToSuspendedSubscriptionSchedules < ActiveRecord::Migration
  def change
  	add_column :suspended_subscription_schedules, :subscription_restart_date, :date
  end
end
