class CreateTableRtransactions < ActiveRecord::Migration
  def change
    create_table :rtransactions do |t|
      t.string 'file_name'
      t.timestamps    
    end
  end
end
