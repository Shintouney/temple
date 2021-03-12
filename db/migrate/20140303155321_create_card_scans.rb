class CreateCardScans < ActiveRecord::Migration
  def change
    create_table :card_scans do |t|
      t.belongs_to :user, index: true
      t.string :card_reference, null: false
      t.datetime :scanned_at, null: false
      t.integer :scan_point, null: false
      t.boolean :accepted, null: false

      t.timestamps
    end
  end
end
