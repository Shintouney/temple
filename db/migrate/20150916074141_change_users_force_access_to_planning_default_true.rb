class ChangeUsersForceAccessToPlanningDefaultTrue < ActiveRecord::Migration
  def change
  	change_column :users, :force_access_to_planning, :boolean, default: true, null: false
  end
end
