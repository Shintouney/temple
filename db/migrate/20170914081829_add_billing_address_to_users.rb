class AddBillingAddressToUsers < ActiveRecord::Migration
  def change
    add_column :users, :billing_address, :string
  end
end
