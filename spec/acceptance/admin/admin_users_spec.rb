require 'acceptance/acceptance_helper'

feature 'Admin Staff Users management' do
  context "logged in as an admin" do
    before { login_as(:admin) }

    let!(:admin_users) { FactoryBot.create_list(:admin, 2) }

    let(:admin_user_attributes) { FactoryBot.attributes_for(:admin) }

    scenario 'Accessing the index' do
      visit admin_admin_users_path

      expect(page).to have_text(admin_users.first.email)
      expect(page.all('table tbody tr').length).to eql(admin_users.size + 1)
    end

    scenario 'Creating a admin_user' do
      admin_users_count = User.with_role(:admin).count

      ResamaniaApi::PushUserWorker.should_receive(:perform_async).with(User.maximum(:id) + 1).once

      visit admin_admin_users_path
      click_link 'new_admin_user'

      fill_in 'user_email', with: admin_user_attributes[:email]
      fill_in 'user_firstname', with: admin_user_attributes[:firstname]
      fill_in 'user_lastname', with: admin_user_attributes[:lastname]
      fill_in 'user_password', with: admin_user_attributes[:password]
      fill_in 'user_password_confirmation', with: admin_user_attributes[:password]
      fill_in 'user_card_reference', with: admin_user_attributes[:user_card_reference]
      click_button 'admin_user_submit'

      expect(current_path).to eql(admin_admin_users_path)
      assert_flash_presence 'admin.admin_users.create.notice'

      expect(User.with_role(:admin).count).to eql(admin_users_count + 1)
      expect(User.last.email).to eql(admin_user_attributes[:email])
    end

    scenario 'Failing to create a admin_user' do
      admin_users_count = User.with_role(:admin).count

      ResamaniaApi::PushUserWorker.should_not_receive(:perform_async)

      visit admin_admin_users_path
      click_link 'new_admin_user'

      click_button 'admin_user_submit'

      expect(current_path).to eql(admin_admin_users_path)

      expect(User.with_role(:admin).count).to eql(admin_users_count)
    end

    scenario 'Editing a admin_user' do
      new_firstname = "Campbell"
      visit edit_admin_admin_user_path(admin_users.first)

      ResamaniaApi::PushUserWorker.should_receive(:perform_async).with(admin_users.first.id).once

      fill_in 'user_firstname', with: new_firstname
      click_button 'admin_user_submit'

      expect(current_path).to eql(admin_admin_users_path)
      assert_flash_presence 'admin.admin_users.update.notice'

      expect(admin_users.first.reload.firstname).to eql(new_firstname)
    end

    scenario 'Failing to edit a admin_user' do
      visit edit_admin_admin_user_path(admin_users.first)

      ResamaniaApi::PushUserWorker.should_not_receive(:perform_async)

      fill_in 'user_email', with: ''
      click_button 'admin_user_submit'

      expect(page).to have_css("#edit_user_#{admin_users.first.id}")
    end

    scenario 'Deleting a admin_user' do
      visit admin_admin_users_path

      ResamaniaApi::DeleteUserWorker.should_receive(:perform_async).with(admin_users.first.id).once

      click_link "destroy_user_#{admin_users.first.id}"

      expect(current_path).to eql(admin_admin_users_path)
      assert_flash_presence 'admin.admin_users.destroy.notice'

      expect(User.exists?(admin_users.first.id)).to be false
    end
  end

  context "logged in as a user" do
    before { login_as(:user) }

    scenario 'Accessing the index' do
      visit admin_admin_users_path

      expect(current_path).not_to eql(admin_admin_users_path)
      assert_flash_presence 'access_denied'
    end
  end
end
