class AddReceiveMailIcalToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :receive_mail_ical, :boolean, null: false, default: true
  end
end
