class AddRestartDateToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :restart_date, :date
  end
end
