class CreateExports < ActiveRecord::Migration
  def change
    create_table :exports do |t|
      t.string :state, null: false, default: 'in_progress'
      t.string :export_type
      t.string :subtype
      t.date :date_start
      t.date :date_end

      t.timestamps
    end
  end
end
