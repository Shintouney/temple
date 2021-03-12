class RemovePaidFromInvoices < ActiveRecord::Migration
  def change
    remove_column :invoices, :paid, :boolean
  end
end
