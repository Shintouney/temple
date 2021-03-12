class AddTargetLinkToAnnounce < ActiveRecord::Migration
  def change
    add_column :announces, :target_link, :string
    add_column :announces, :external_link, :boolean, default: false
  end
end
