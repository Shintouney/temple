class AddForceAccessToPlanningToUsers < ActiveRecord::Migration
  def change
    add_column :users, :force_access_to_planning, :boolean, default: false, null: false
  end
end
