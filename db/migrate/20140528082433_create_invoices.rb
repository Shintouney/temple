class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.date :start_at
      t.date :end_at
      t.date :subscription_period_start_at
      t.date :subscription_period_end_at
      t.date :next_payment_at
      t.boolean :paid

      t.timestamps
    end
  end
end
