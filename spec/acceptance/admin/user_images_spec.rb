require 'acceptance/acceptance_helper'

feature 'Admin user images management' do
  context "logged in as an admin" do
    before { login_as(:admin) }

    let!(:user) { create_subscribed_user }
    let!(:user_image) { FactoryBot.create(:user_image, user: user) }

    let(:image_file) do
      Rails.root.join('spec/fixtures/images/logo_novagile.png')
    end

    scenario "Displaying the user images" do
      visit admin_user_path(user)
      click_link 'user_user_images_link'

      expect(page.all('ul#user_images li').length).to eql(1)
    end

    scenario "Trying to create an user_image without an image file" do
      user_image_count = UserImage.count

      visit admin_user_path(user)
      click_link 'user_user_images_link'

      click_button 'user_image_submit'

      expect(current_path).to eql(admin_user_user_images_path(user))
      assert_flash_presence 'admin.user_images.create.alert'

      expect(UserImage.count).to eql(user_image_count)
    end

    scenario "Creating an user_image" do
      user_image_count = UserImage.count

      visit admin_user_user_images_path(user)

      attach_file("user_image_image", image_file)

      click_button 'user_image_submit'

      expect(current_path).to eql(admin_user_user_images_path(user))
      assert_flash_presence 'admin.user_images.create.notice'

      expect(UserImage.count).to eql(user_image_count + 1)

      last_user_image = UserImage.last
      expect(last_user_image.user).to eql(user)
    end

    scenario "Making an user_image the profile image" do
      visit admin_user_user_images_path(user)

      click_link "make_profile_image_user_image_#{user_image.id}"

      expect(current_path).to eql(admin_user_user_images_path(user))
      assert_flash_presence 'admin.user_images.make_profile_image.notice'

      expect(user.reload.profile_user_image.id).to eql(user_image.id)
    end

    scenario "Deleting an user_image" do
      visit admin_user_user_images_path(user)

      click_link "destroy_user_image_#{user_image.id}"

      expect(current_path).to eql(admin_user_user_images_path(user))
      assert_flash_presence 'admin.user_images.destroy.notice'

      expect(UserImage.exists?(user_image.id)).to be false
    end
  end
end
