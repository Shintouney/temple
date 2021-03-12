require 'acceptance/acceptance_helper'

feature "Edit profile information" do
  context "logged in as an user" do
    let!(:user) { create_subscribed_user }

    before do
      login_user(user, FactoryBot.attributes_for(:user)[:password])
    end

    scenario 'Fill in profile from the edit profile page' do
      visit root_path

      find('#edit-profile-link').click
      expect(current_path).to eql('/account/profile/edit')
      fill_in 'profile_user_attributes_position', with: 'CEO'
      check 'profile_boxing_disciplines_wished_french'

      page.find("#profile_submit").click

      assert_flash_presence I18n.t('flash.account.profiles.update.notice')
      expect(current_path).to eql(account_root_path)
      expect(page).to_not have_text(I18n.t('account.dashboard.index.welcome'))

      user.reload
      expect(user.position).to eql('CEO')
      expect(user.profile.boxing_disciplines_wished).to eql(['french'])
    end

    scenario 'Fill in profil in edit profile page with bad values' do
      visit root_path
      find('#edit-profile-link').click
      fill_in 'profile_user_attributes_linkedin_url', with: 'plop'
      page.find("#profile_submit").click
      assert_flash_presence I18n.t('flash.account.profiles.update.alert')
    end
  end
end
