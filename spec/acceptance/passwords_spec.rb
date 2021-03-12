require 'acceptance/acceptance_helper'

feature "Password recovery", %{
  In order to regain access to my account
  As a user
  I want to ask for a new password
  And change my password
} do

  let(:old_password) { 'password 12345' }
  let(:new_password) { 'new_password 12345' }
  let!(:user) { FactoryBot.create(:user, password: old_password, password_confirmation: old_password) }

  def submit_new_password_form(email)
    visit new_password_path

    fill_in 'reset_password_request_email', with: email
    click_button 'new_password_submit'
  end

  context "without an existing account" do
    scenario 'asking for a new password with an unregistered email' do
      emails_count = email_queue.size
      submit_new_password_form 'foo@example.com'

      expect(current_path).to eql(new_password_path)
      assert_flash_presence 'passwords.create.alert'

      expect(email_queue.size).to eql(emails_count)
    end

    scenario 'asking for a new password with an unregistered email' do
      emails_count = email_queue.size
      submit_new_password_form ''

      expect(current_path).to eql(new_password_path)
      assert_flash_presence 'passwords.create.alert'

      expect(email_queue.size).to eql(emails_count)
    end
  end

  context "given an existing user" do
    scenario 'asking for a new password' do
      emails_count = email_queue.size
      submit_new_password_form user.email

      expect(current_path).to eql(login_path)
      assert_flash_presence 'passwords.create.notice'

      expect(user.reload.reset_password_token).not_to be_blank
      expect(email_queue.size).to eql(emails_count + 1)
    end

    scenario 'trying to reset my password without a valid token' do
      visit edit_password_path

      expect(current_path).to eql(login_path)
      assert_flash_presence 'passwords.edit.alert'
    end

    context "with a valid password reset token" do
      before { user.deliver_reset_password_instructions! }

      scenario "trying to reset my password without supplying a new password" do
        visit edit_password_path(token: user.reset_password_token)

        click_button 'edit_password_submit'

        expect(User.authenticate(user.email, '')).to be_nil
      end

      scenario "trying to reset my password with an invalid password confirmation" do
        visit edit_password_path(token: user.reset_password_token)

        fill_in 'user_password_updater_password', with: new_password
        fill_in 'user_password_updater_password_confirmation', with: "#{new_password}fail"
        click_button 'edit_password_submit'

        expect(User.authenticate(user.email, new_password)).to be_nil
      end

      scenario "resetting my password" do
        visit edit_password_path(token: user.reset_password_token)

        fill_in 'user_password_updater_password', with: new_password
        fill_in 'user_password_updater_password_confirmation', with: new_password
        click_button 'edit_password_submit'

        expect(current_path).to eql(account_root_path)
        assert_flash_presence 'passwords.update.notice'
        expect(User.authenticate(user.email, new_password)).to eql(user)
      end
    end
  end

end
