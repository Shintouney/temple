require 'acceptance/acceptance_helper'

feature 'Sessions', %{
  In order to access the application
  As a user
  I want to log in
} do

  let(:password) { 'password 12345' }
  let!(:user) { FactoryBot.create(:user, password: password, password_confirmation: password) }

  scenario 'successful login' do
    login_user(user, password)

    expect(current_path).to eql(account_root_path)
  end

  scenario 'failed login with wrong password' do
    login_user(user, 'wrong')

    expect(page.find('#session_email').value).to eql(user.email)

    expect(current_path).to eql('/sessions')
    assert_flash_presence 'sessions.create.alert'
  end

  scenario 'failed login with wrong login' do
    wrong_user = User.new(email: 'wrong@example.com')
    login_user(wrong_user, password)

    expect(current_path).to eql('/sessions')
    assert_flash_presence 'sessions.create.alert'
  end

  scenario 'logging out' do
    login_user(user, password)
    visit logout_path

    expect(current_path).to eql(login_path)
    assert_flash_presence 'sessions.destroy.notice'
  end

  scenario 'accessing the sessions path' do
    visit '/sessions'

    expect(current_path).to eql(login_path)
  end

  scenario 'Trying to access the login page while being logged in' do
    login_user(user, password)
    visit login_path

    expect(current_path).not_to eql(login_path)
  end
end
