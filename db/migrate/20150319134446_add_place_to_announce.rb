class AddPlaceToAnnounce < ActiveRecord::Migration
  def change
    add_column :announces, :place, :string, default: 'all'
  end
end
