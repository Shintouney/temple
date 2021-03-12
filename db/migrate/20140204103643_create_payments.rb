class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.timestamps

      t.references :user, null: false
      t.decimal :price, precision: 8, scale: 2, default: 0, null: false
      t.string :paybox_credit_card_reference
      t.string :paybox_transaction
      t.string :credit_card_number, null: false
      t.string :credit_card_cvv, null: false
      t.integer :credit_card_expiration_month, null: false
      t.integer :credit_card_expiration_year, null: false
      t.string :state, null: false
    end

    remove_column :orders, :paybox_transaction, :string
  end
end
