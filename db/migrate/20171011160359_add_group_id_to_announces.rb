class AddGroupIdToAnnounces < ActiveRecord::Migration
  def change
  	add_column :announces, :group_id, :integer
  end
end
