class AddActiveToAnnounce < ActiveRecord::Migration
  def change
    add_column :announces, :active, :boolean
  end
end
