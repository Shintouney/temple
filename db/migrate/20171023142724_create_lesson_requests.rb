class CreateLessonRequests < ActiveRecord::Migration
  def change
    create_table :lesson_requests do |t|
      t.string :first_coach_name
      t.string :second_coach_name
      t.text :comment
      t.belongs_to :user
      t.timestamps
    end
  end
end
