class AddPayboxUserReferenceToUser < ActiveRecord::Migration
  def change
    add_column :users, :paybox_user_reference, :string
  end
end
