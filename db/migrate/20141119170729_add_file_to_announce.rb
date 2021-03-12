class AddFileToAnnounce < ActiveRecord::Migration
  def self.up
    add_attachment :announces, :file
  end

  def self.down
    remove_attachment :announces, :file
  end
end
