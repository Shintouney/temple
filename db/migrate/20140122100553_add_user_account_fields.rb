class AddUserAccountFields < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :firstname
      t.string :lastname

      t.string :street1
      t.string :street2
      t.string :postal_code
      t.string :city

      t.string :phone

      t.date :birthdate
      t.string :gender
    end
  end
end
