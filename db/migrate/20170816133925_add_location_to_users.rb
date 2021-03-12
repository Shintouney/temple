class AddLocationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :location, :string

    User.with_role(:admin).each { |user| user.update_attribute(:location, 'moliere') }
    User.with_role(:staff).each { |user| user.update_attribute(:location, 'moliere') }
  end
end
