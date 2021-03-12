class AddMaxSpotsToLessonsAndLessonTemplates < ActiveRecord::Migration
  def change
    add_column :lessons, :max_spots, :integer
    add_column :lesson_templates, :max_spots, :integer
  end
end
