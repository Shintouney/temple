class RemoveUserCreditCardFields < ActiveRecord::Migration
  def up
    remove_column :users, :paybox_credit_card_reference
    remove_column :users, :credit_card_number
    remove_column :users, :credit_card_cvv
    remove_column :users, :credit_card_expiration_month
    remove_column :users, :credit_card_expiration_year
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
