class ChangeSubscriptionPlansDefaults < ActiveRecord::Migration
  def up
    change_table :subscription_plans do |t|
      t.change :discounted_price_te, :decimal, precision: 8, scale: 2, null: true, default: nil
      t.change :discounted_price_ati, :decimal, precision: 8, scale: 2, null: true, default: nil
    end
  end

  def down
    change_table :subscription_plans do |t|
      t.change :discounted_price_te, :decimal, precision: 8, scale: 2, null: false, default: 0
      t.change :discounted_price_ati, :decimal, precision: 8, scale: 2, null: false, default: 0
    end
  end
end
