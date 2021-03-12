require 'acceptance/acceptance_helper'

feature 'Admin Staff Users management' do
  context "logged in as an admin" do
    before { login_as(:admin) }

    let!(:staff_users) { FactoryBot.create_list(:staff, 2) }

    let(:staff_user_attributes) { FactoryBot.attributes_for(:staff) }

    scenario 'Accessing the index' do
      visit admin_staff_users_path

      expect(page).to have_text(staff_users.first.email)
      expect(page.all('table tbody tr').length).to eql(staff_users.size)
    end

    scenario 'Creating a staff_user' do
      staff_users_count = User.with_role(:staff).count

      ResamaniaApi::PushUserWorker.should_receive(:perform_async).with(User.maximum(:id) + 1).once

      visit admin_staff_users_path
      click_link 'new_staff_user'

      fill_in 'user_email', with: staff_user_attributes[:email]
      fill_in 'user_firstname', with: staff_user_attributes[:firstname]
      fill_in 'user_lastname', with: staff_user_attributes[:lastname]
      fill_in 'user_card_reference', with: staff_user_attributes[:card_reference]
      click_button 'staff_user_submit'

      expect(current_path).to eql(admin_staff_users_path)
      assert_flash_presence 'admin.staff_users.create.notice'

      expect(User.with_role(:staff).count).to eql(staff_users_count + 1)
      expect(User.last.email).to eql(staff_user_attributes[:email])
    end

    scenario 'Failing to create a staff_user' do
      staff_users_count = User.with_role(:staff).count

      ResamaniaApi::PushUserWorker.should_not_receive(:perform_async)

      visit admin_staff_users_path
      click_link 'new_staff_user'

      click_button 'staff_user_submit'

      expect(current_path).to eql(admin_staff_users_path)

      expect(User.with_role(:staff).count).to eql(staff_users_count)
    end

    scenario 'Editing a staff_user' do
      new_firstname = "Campbell"
      visit edit_admin_staff_user_path(staff_users.first)

      ResamaniaApi::PushUserWorker.should_receive(:perform_async).with(staff_users.first.id).once

      fill_in 'user_firstname', with: new_firstname
      click_button 'staff_user_submit'

      expect(current_path).to eql(admin_staff_users_path)
      assert_flash_presence 'admin.staff_users.update.notice'

      expect(staff_users.first.reload.firstname).to eql(new_firstname)
    end

    scenario 'Failing to edit a staff_user' do
      visit edit_admin_staff_user_path(staff_users.first)

      ResamaniaApi::PushUserWorker.should_not_receive(:perform_async)

      fill_in 'user_email', with: ''
      click_button 'staff_user_submit'

      expect(page).to have_css("#edit_user_#{staff_users.first.id}")
    end

    scenario 'Deleting a staff_user' do
      visit admin_staff_users_path

      ResamaniaApi::DeleteUserWorker.should_receive(:perform_async).with(staff_users.first.id).once

      click_link "destroy_user_#{staff_users.first.id}"

      expect(current_path).to eql(admin_staff_users_path)
      assert_flash_presence 'admin.staff_users.destroy.notice'

      expect(User.exists?(staff_users.first.id)).to be false
    end
  end

  context "logged in as a user" do
    before { login_as(:user) }

    scenario 'Accessing the index' do
      visit admin_staff_users_path

      expect(current_path).not_to eql(admin_staff_users_path)
      assert_flash_presence 'access_denied'
    end
  end
end
