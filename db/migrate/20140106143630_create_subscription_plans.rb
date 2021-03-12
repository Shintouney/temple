class CreateSubscriptionPlans < ActiveRecord::Migration
  def change
    create_table :subscription_plans do |t|
      t.timestamps

      t.decimal :price, precision: 8, scale: 2, null: false

      t.string :periodicity
      t.integer :duration, null: false

      t.string :name, null: false
      t.text :description
    end
  end
end
