class CreateLessons < ActiveRecord::Migration
  def change
    create_table :lessons do |t|
      t.timestamps

      t.references :lesson_template

      t.string :room
      t.string :coach_name
      t.string :activity

      t.datetime :start_at
      t.datetime :end_at

      t.boolean :cancelled, default: false
    end
  end
end
