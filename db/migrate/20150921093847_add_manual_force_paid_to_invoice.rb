class AddManualForcePaidToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :manual_force_paid, :boolean, default: false, null: false
  end
end
