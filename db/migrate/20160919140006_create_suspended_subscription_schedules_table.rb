class CreateSuspendedSubscriptionSchedulesTable < ActiveRecord::Migration
	def change
		create_table :suspended_subscription_schedules do |t|
			t.belongs_to :user
			t.datetime :scheduled_at, default: nil
			t.timestamps
		end
	end
end
