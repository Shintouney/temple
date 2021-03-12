class AddFieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :professional_sector, :string
    add_column :users, :position, :string
    add_column :users, :company, :string
    add_column :users, :professional_address, :string
    add_column :users, :education, :string
    add_column :users, :heard_about_temple_from, :string
  end
end
