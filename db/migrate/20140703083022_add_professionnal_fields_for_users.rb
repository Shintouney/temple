class AddProfessionnalFieldsForUsers < ActiveRecord::Migration
  def change
    add_column :users, :professional_zipcode, :string
    add_column :users, :professional_city, :string
  end
end
