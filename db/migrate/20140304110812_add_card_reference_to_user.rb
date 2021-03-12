class AddCardReferenceToUser < ActiveRecord::Migration
  def change
    add_column :users, :card_reference, :string
  end
end
