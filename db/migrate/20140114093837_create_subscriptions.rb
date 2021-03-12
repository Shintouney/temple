class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.timestamps

      t.references :user, null: false
      t.references :subscription_plan, null: false

      t.string :state, null: false

      t.date :start_at
      t.date :end_at
      t.date :renew_at
    end
  end
end
