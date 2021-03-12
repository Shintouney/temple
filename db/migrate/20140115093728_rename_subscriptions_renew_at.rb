class RenameSubscriptionsRenewAt < ActiveRecord::Migration
  def change
    rename_column :subscriptions, :renew_at, :next_payment_at
  end
end
