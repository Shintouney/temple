class CreateLessonBookings < ActiveRecord::Migration
  def change
    create_table :lesson_bookings do |t|
      t.timestamps

      t.references :lesson, null: false
      t.references :user, null: false
    end
  end
end
