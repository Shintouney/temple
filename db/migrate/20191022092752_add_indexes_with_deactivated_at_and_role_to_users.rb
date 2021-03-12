class AddIndexesWithDeactivatedAtAndRoleToUsers < ActiveRecord::Migration
  def change
    add_index :users, [:deactivated_at, :role]
  end
end
