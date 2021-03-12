class RemoveStateNullConstraintForOrders < ActiveRecord::Migration
  def change
    change_column :orders, :state, :string, null: true
  end
end
