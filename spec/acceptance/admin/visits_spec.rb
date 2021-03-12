require 'acceptance/acceptance_helper'

feature "Admin visits" do
  context "logged in as an admin" do
    let!(:visits) { FactoryBot.create_list(:visit, 6, started_at: Date.today - 2.weeks) }
    let!(:old_visits) { FactoryBot.create_list(:visit, 2, started_at: Date.today - 4.months) }

    before do
      login_as(:admin)
    end

    scenario 'Accessing the visits logs' do
      visit logs_admin_visits_path

      expect(current_path).to eql(logs_admin_visits_path)

      expect(page.all('#visits_logs tbody tr').count).to eql(visits.count)
    end
  end

  context "logged in as a user" do
    before { login_as(:user) }

    scenario 'Accessing the visits logs' do
      visit logs_admin_visits_path

      expect(current_path).not_to eql(logs_admin_visits_path)
      assert_flash_presence 'access_denied'
    end
  end

  context "not logged in" do
    scenario 'Accessing the visits logs' do
      visit logs_admin_visits_path

      expect(current_path).to eql(login_path)
    end
  end
end
