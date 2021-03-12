class AddRequireIcsToNotificationSchedule < ActiveRecord::Migration
  def change
  	add_column :notification_schedules, :require_ics, :boolean, default: true, null: false
  end
end
