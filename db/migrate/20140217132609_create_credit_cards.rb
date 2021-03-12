class CreateCreditCards < ActiveRecord::Migration
  def change
    create_table :credit_cards do |t|
      t.belongs_to :user, null: false
      t.string :firstname, null: false
      t.string :lastname, null: false
      t.string :number, null: false
      t.string :cvv, null: false
      t.integer :expiration_month, null: false
      t.integer :expiration_year, null: false
      t.string :brand, null: false
      t.string :paybox_reference

      t.timestamps
    end
  end
end
