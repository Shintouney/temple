class RemoveAnnounceTypeFromAnnounce < ActiveRecord::Migration
  def change
    remove_column :announces, :announce_type
  end
end
