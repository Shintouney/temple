class AddRefundedAtOnInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :refunded_at, :datetime
  end
end
