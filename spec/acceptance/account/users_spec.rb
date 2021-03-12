require 'acceptance/acceptance_helper'

feature "Account User infos management" do
  context "logged in as a user" do
    let!(:user) { FactoryBot.build(:user, :with_registered_credit_card) }

    before do
      login_with(user)
      FactoryBot.create(:subscription, user: user, state: 'running')
    end

    scenario 'Editing the user data' do
      new_phone = "07 45 12 45 89"
      visit account_user_path
      fill_in 'user_phone', with: new_phone
      click_button 'user_submit'
      expect(current_path).to eql(account_user_path)
      assert_flash_presence 'account.users.update.notice'
      user.reload
      expect(user.phone).to eql(new_phone)
    end

    scenario 'Failing to edit user data' do
      visit account_user_path
      fill_in 'user_phone', with: ''
      click_button 'user_submit'
      assert_flash_presence 'account.users.update.alert'
    end
  end

  context "logged in as an admin" do
    before { login_as(:admin) }

    scenario 'Accessing the index' do
      visit account_user_path
      expect(current_path).to eql(admin_root_path)
      assert_flash_presence 'access_unavailable'
    end
  end

  context "not logged in" do
    scenario 'Accessing the index' do
      visit account_user_path
      expect(current_path).to eql(login_path)
    end
  end
end
