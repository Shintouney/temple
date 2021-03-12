class AddCancelAtOnInvoices < ActiveRecord::Migration
  def change
  	add_column :invoices, :canceled_at, :datetime
  end
end
