class CreateUnsubscribeRequests < ActiveRecord::Migration
  def change
    create_table :unsubscribe_requests do |t|
    	t.string :firstname
    	t.string :lastname
    	t.string :phone
    	t.string :email

    	t.date :desired_date
    	t.boolean :health_reason
    	t.boolean :moving_reason
    	t.string :other_reason

    	t.timestamps
    end
  end
end
