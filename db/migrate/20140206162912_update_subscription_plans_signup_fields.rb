class UpdateSubscriptionPlansSignupFields < ActiveRecord::Migration
  def up
    change_table :subscription_plans do |t|
      t.integer :commitment_period, null: false, default: 0
      t.boolean :require_sponsorship, null: false, default: false
      t.string :code
      t.integer :discount_period, null: false, default: 0
      t.decimal :discounted_price_te, precision: 8, scale: 2, null: false, default: 0
      t.decimal :discounted_price_ati, precision: 8, scale: 2, null: false, default: 0

      t.remove :next_subscription_plan_id
      t.remove :max_duration
      t.remove :periodicity
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
