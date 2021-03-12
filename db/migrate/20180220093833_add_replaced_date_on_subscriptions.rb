class AddReplacedDateOnSubscriptions < ActiveRecord::Migration
  def change
  	add_column :subscriptions, :replaced_date, :date
  end
end
