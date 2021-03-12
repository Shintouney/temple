class AddMarkedAsDeletedToMandate < ActiveRecord::Migration
  def change
    add_column :mandates, :marked_as_deleted, :boolean, default: false, null: false
  end
end
