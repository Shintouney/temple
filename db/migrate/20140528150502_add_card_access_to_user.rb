class AddCardAccessToUser < ActiveRecord::Migration
  def up
    add_column :users, :card_access, :integer
  end

  def down
    remove_column :users, :card_access
  end
end
