require 'acceptance/acceptance_helper'

feature "Account static pages" do
  context "logged in as a user" do
    let!(:user) { FactoryBot.build(:user, :with_registered_credit_card) }

    before do
      login_with(user)
      FactoryBot.create(:subscription, user: user, state: 'running')
    end

    scenario 'Accessing the cgv page' do
      visit account_page_path('cgv')

      expect(current_path).to eql('/account/pages/cgv')
    end
  end

  context "logged in as an admin" do
    before { login_as(:admin) }

    scenario 'Accessing the cgv page' do
      visit account_page_path('cgv')

      expect(current_path).to eql(admin_root_path)
      assert_flash_presence 'access_unavailable'
    end
  end

  context "not logged in" do
    scenario 'Accessing the cgv page' do
      visit account_page_path('cgv')

      expect(current_path).to eql(login_path)
    end
  end
end
