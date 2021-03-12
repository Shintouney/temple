class ChangeForceAccessToPlanningDefaultFalseForUsers < ActiveRecord::Migration
  def change
    change_column :users, :force_access_to_planning, :boolean, default: false, null: false
  end
end
