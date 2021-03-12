require 'acceptance/acceptance_helper'

feature 'Home page' do

  scenario 'Accessing the homepage being logged out' do
    visit root_path

    expect(current_path).to eql(login_path)
  end

  context "logged in as a user" do
    before { login_as(:user) }

    scenario 'Accessing the homepage' do
      visit root_path

      expect(current_path).to eql(account_root_path)
    end
  end

  context "logged in as an admin" do
    before { login_as(:admin) }

    scenario 'Accessing the homepage' do
      visit root_path

      expect(current_path).to eql(admin_root_path)
    end
  end

end
