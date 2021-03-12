class CreateInvoicesPayments < ActiveRecord::Migration
  def change
    create_table :invoices_payments do |t|
      t.belongs_to :invoice, index: true
      t.belongs_to :payment, index: true
    end
  end
end
