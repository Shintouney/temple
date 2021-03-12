class AddIndexStartAtToSubscriptions < ActiveRecord::Migration
  def change
    add_index :subscriptions, :start_at
  end
end
