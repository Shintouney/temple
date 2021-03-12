class AddReceiveBookingConfirmationToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :receive_booking_confirmation, :boolean, default: true, null: false
  end
end
