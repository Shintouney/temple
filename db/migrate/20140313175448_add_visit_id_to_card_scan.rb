class AddVisitIdToCardScan < ActiveRecord::Migration
  def change
    add_reference :card_scans, :visit, index: true
  end
end
