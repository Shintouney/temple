class CreateVisits < ActiveRecord::Migration
  def change
    create_table :visits do |t|
      t.belongs_to :user, index: true
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end
  end
end
