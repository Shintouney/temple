class AddOriginLocationToSunscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :origin_location, :string
  end
end
