class RemoveRequireIcsFromNotificationSchedule < ActiveRecord::Migration
  def change
  	remove_column :notification_schedules, :require_ics
  end
end
