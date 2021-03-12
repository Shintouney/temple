class RemoveRequireSponsorshipFromSubscriptionPlans < ActiveRecord::Migration
  def up
    change_table :subscription_plans do |t|
      t.remove :require_sponsorship
    end
  end

  def down
    change_table :subscription_plans do |t|
      t.boolean :require_sponsorship, null: false, default: false
    end
  end
end
