class AddSponsorIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sponsor_id, :integer, references: :users
  end
end
