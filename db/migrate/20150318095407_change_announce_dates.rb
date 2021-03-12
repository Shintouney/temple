class ChangeAnnounceDates < ActiveRecord::Migration
  def change
    change_column :announces, :start_at, :date
    change_column :announces, :end_at, :date
  end
end
