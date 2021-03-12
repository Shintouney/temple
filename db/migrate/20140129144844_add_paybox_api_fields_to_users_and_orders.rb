class AddPayboxApiFieldsToUsersAndOrders < ActiveRecord::Migration
  def change
    add_column :users, :paybox_credit_card_reference, :string
    add_column :orders, :paybox_transaction, :string
  end
end
