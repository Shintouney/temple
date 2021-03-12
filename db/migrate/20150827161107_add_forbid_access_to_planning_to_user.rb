class AddForbidAccessToPlanningToUser < ActiveRecord::Migration
  def change
    add_column :users, :forbid_access_to_planning, :boolean, default: :false
  end
end
