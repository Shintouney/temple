class AddProfileUserImageIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :profile_user_image_id, :integer, references: :user_images
  end
end
