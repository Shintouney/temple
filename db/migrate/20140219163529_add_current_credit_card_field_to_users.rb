class AddCurrentCreditCardFieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :current_credit_card_id, :integer, references: :credit_cards
  end
end
