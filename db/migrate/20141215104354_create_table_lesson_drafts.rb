class CreateTableLessonDrafts < ActiveRecord::Migration
  def change
    create_table :lesson_drafts do |t|
      t.datetime "created_at"
      t.datetime "updated_at"

      t.string   "room"
      t.string   "coach_name"
      t.string   "activity"

      t.time     "start_at_hour", null: false
      t.time     "end_at_hour",   null: false

      t.integer  "weekday",       null: false
      t.integer  "max_spots"
    end

    add_column :lessons, :lesson_draft_id, :integer
  end
end
