class CreateLessonTemplates < ActiveRecord::Migration
  def change
    create_table :lesson_templates do |t|
      t.timestamps

      t.string :room
      t.string :coach_name
      t.string :activity

      t.integer :weekday, null: false
      t.time :start_at_hour, null: false
      t.integer :duration, null: false
    end
  end
end
