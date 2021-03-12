require 'acceptance/acceptance_helper'

feature "User dashboard" do
  context "logged in as a user" do
    let!(:user) { FactoryBot.build(:user, :with_running_subscription) }

    before do
      login_with(user)
    end

    scenario 'Accessing the index' do
      visit account_root_path

      expect(current_path).to eql(account_root_path)
    end
  end

  context "logged in as an admin" do
    before { login_as(:admin) }

    scenario 'Accessing the index' do
      visit account_root_path

      expect(current_path).to eql(admin_root_path)
      assert_flash_presence 'access_unavailable'
    end
  end

  context "logged in as user without profile" do
    before { login_as(:user) }

    scenario 'Accessing the dashboard link to edit profile' do
      visit account_root_path

      click_link I18n.t('account.dashboard.index.welcome')
      expect(page).to have_text(I18n.t('account.profiles.edit.title'))
    end
  end

  context "logged in as user with completed profile" do
    let!(:user) { FactoryBot.build(:user, :with_profile) }

    before { login_with(user) }

    scenario 'Accessing the dashboard link to edit profile' do
      visit account_root_path

      expect(page).not_to have_text(I18n.t('account.dashboard.index.welcome'))
    end
  end

  context "not logged in" do
    scenario 'Accessing the index' do
      visit account_root_path

      expect(current_path).to eql(login_path)
    end
  end
end
