class CreateAnnounces < ActiveRecord::Migration
  def change
    create_table :announces do |t|
      t.string :announce_type, null: false, default: 'text'
      t.text :content
      t.datetime :start_at
      t.datetime :end_at

      t.timestamps
    end
  end
end
