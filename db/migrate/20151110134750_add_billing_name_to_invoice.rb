class AddBillingNameToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :billing_name, :string
  end
end
