class AddSlimpayDirectDebitIdAndSlimpayStatusToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :slimpay_direct_debit_id, :string, references: nil
    add_column :payments, :slimpay_status, :string
  end
end
