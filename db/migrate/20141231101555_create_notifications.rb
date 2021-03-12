class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :user
      t.references :sourceable, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
