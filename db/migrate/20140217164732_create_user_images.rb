class CreateUserImages < ActiveRecord::Migration
  def change
    create_table :user_images do |t|
      t.timestamps

      t.references :user, null: false

      t.attachment :image
    end
  end
end
