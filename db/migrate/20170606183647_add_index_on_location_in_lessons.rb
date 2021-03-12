class AddIndexOnLocationInLessons < ActiveRecord::Migration
  def change
    add_index :lessons, :location
    add_index :lesson_drafts, :location
    add_index :lesson_templates, :location
  end
end
