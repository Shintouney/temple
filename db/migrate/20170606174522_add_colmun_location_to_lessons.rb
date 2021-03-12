class AddColmunLocationToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :location, :string, null: false, default: "moliere"
    add_column :lesson_templates, :location, :string, null: false, default: "moliere"
    add_column :lesson_drafts, :location, :string, null: false, default: "moliere"
  end
end
