class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :sports_practiced
      t.string :attendance_rate
      t.string :fitness_goals
      t.string :boxing_disciplines_practiced
      t.string :boxing_level
      t.string :boxing_disciplines_wished
      t.string :attendance_periods
      t.string :weekdays_attendance_hours
      t.string :weekend_attendance_hours
      t.string :transportation_means
      t.references :user, null: false
    end
  end
end
