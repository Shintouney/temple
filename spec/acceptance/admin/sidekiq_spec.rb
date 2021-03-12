require 'acceptance/acceptance_helper'

feature 'Admin Sidekiq monitoring access', type: :feature do
  context "logged in as an admin" do
    before { login_as(:admin) }

    scenario 'Accessing the Sidekiq monitoring page' do
      visit '/admin/sidekiq'

      expect(current_path).to eql '/admin/sidekiq'

      expect(page).to have_content('Dashboard')
    end
  end

  context "logged in as a user" do
    before { login_as(:user) }

    scenario 'Accessing the Sidekiq monitoring page' do
      expect { visit '/admin/sidekiq' }.to raise_error(ActionController::RoutingError)
    end
  end
end
