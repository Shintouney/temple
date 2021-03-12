class RemoveOrdersPaymentsAssociation < ActiveRecord::Migration
  def up
    drop_table :orders_payments
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
