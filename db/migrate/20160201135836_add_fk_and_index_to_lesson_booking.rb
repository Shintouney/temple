class AddFkAndIndexToLessonBooking < ActiveRecord::Migration
  def change
    add_index :lesson_bookings, [:user_id, :lesson_id], unique: true
  end
end
