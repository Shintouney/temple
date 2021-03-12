class AddBillingNameToUser < ActiveRecord::Migration
  def change
    add_column :users, :billing_name, :string
  end
end
