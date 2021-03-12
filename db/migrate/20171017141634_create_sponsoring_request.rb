class CreateSponsoringRequest < ActiveRecord::Migration
  def change
    create_table :sponsoring_requests do |t|
      t.string :firstname
      t.string :lastname
      t.string :phone
      t.string :email

      t.belongs_to :user
      t.timestamps
    end
  end
end
