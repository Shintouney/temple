class AddDiscountPeriodToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :discount_period, :integer, default: 0
  end
end
