class AddSubscriptionPlansDisplayFields < ActiveRecord::Migration
  def change
    change_table :subscription_plans do |t|
      t.boolean :displayable, null: false, default: false
      t.boolean :favorite, null: false, default: false
    end
  end
end
