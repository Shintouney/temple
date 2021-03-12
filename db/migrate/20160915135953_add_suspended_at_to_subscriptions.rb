class AddSuspendedAtToSubscriptions < ActiveRecord::Migration
  def change
  	add_column :subscriptions, :suspended_at, :date 
  end
end
