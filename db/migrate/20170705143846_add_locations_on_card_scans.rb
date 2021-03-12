class AddLocationsOnCardScans < ActiveRecord::Migration
  def change
    add_column :card_scans, :location, :string

    CardScan.all.each { |card_scan| card_scan.update_attribute(:location, 'moliere') }
  end
end
