class RemoveCreditCardFieldsFromPayments < ActiveRecord::Migration
  def up
    remove_column :payments, :credit_card_number
    remove_column :payments, :credit_card_cvv
    remove_column :payments, :credit_card_expiration_month
    remove_column :payments, :credit_card_expiration_year
    remove_column :payments, :paybox_credit_card_reference
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
