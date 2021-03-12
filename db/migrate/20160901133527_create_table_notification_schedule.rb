class CreateTableNotificationSchedule < ActiveRecord::Migration
  def change
    create_table :notification_schedules do |t|
      t.datetime :scheduled_at
      t.belongs_to :user, index: true
      t.belongs_to :lesson, index: true
    end
  end
end
