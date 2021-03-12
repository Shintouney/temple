class CreateMandates < ActiveRecord::Migration
  def change
    create_table :mandates do |t|
      t.references :user
      t.string :slimpay_rum
      t.string :slimpay_state
      t.datetime :slimpay_created_at
      t.datetime :slimpay_revoked_at
      t.string :slimpay_approval_url
      t.string :slimpay_order_reference
      t.string :slimpay_order_state

      t.timestamps
    end
  end
end
