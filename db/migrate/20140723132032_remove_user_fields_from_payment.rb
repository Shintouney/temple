class RemoveUserFieldsFromPayment < ActiveRecord::Migration
  def change
    remove_column :payments, :user_firstname, :string
    remove_column :payments, :user_lastname, :string
    remove_column :payments, :user_street1, :string
    remove_column :payments, :user_street2, :string
    remove_column :payments, :user_postal_code, :string
    remove_column :payments, :user_city, :string
  end
end
