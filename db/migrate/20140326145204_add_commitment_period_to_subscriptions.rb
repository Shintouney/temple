class AddCommitmentPeriodToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :commitment_period, :integer, default: 0, null: false
  end
end
