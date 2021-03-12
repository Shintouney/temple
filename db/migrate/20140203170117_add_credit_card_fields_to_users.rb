class AddCreditCardFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :credit_card_number, :string
    add_column :users, :credit_card_cvv, :string
    add_column :users, :credit_card_expiration_month, :integer
    add_column :users, :credit_card_expiration_year, :integer
  end
end
