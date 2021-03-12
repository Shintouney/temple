class AddSponsorshipPricesToSubscriptionPlans < ActiveRecord::Migration
  def up
    change_table :subscription_plans do |t|
      t.decimal :sponsorship_price_te, precision: 8, scale: 2, default: nil
      t.decimal :sponsorship_price_ati, precision: 8, scale: 2, default: nil
    end
  end

  def down
    change_table :subscription_plans do |t|
      t.remove :sponsorship_price_te
      t.remove :sponsorship_price_ati
    end
  end
end
