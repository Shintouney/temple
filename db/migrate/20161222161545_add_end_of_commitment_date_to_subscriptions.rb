class AddEndOfCommitmentDateToSubscriptions < ActiveRecord::Migration
  def change
  	add_column :subscriptions, :end_of_commitment_date, :date
  end
end
