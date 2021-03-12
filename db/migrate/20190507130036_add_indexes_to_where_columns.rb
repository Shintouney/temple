class AddIndexesToWhereColumns < ActiveRecord::Migration
  def change
    add_index :exports, :state
    add_index :payments, :state
    add_index :subscriptions, :state
  end
end
