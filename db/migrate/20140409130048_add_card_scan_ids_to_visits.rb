class AddCardScanIdsToVisits < ActiveRecord::Migration
  def up
    add_reference :visits, :checkin_scan, references: :card_scans
    add_reference :visits, :checkout_scan, references: :card_scans
    remove_reference :card_scans, :visit
  end

  def down
    add_reference :card_scans, :visit, index: true
    remove_reference :visits, :checkin_scan
    remove_reference :visits, :checkout_scan
  end
end
