class AddCreditCardIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :credit_card_id, :integer
  end
end
