require 'acceptance/acceptance_helper'

feature "Admin card scans" do
  context "logged in as an admin" do
    let!(:card_scans) { FactoryBot.create_list(:card_scan, 6, scanned_at: Date.today - 1.week) }
    let!(:old_card_scans) { FactoryBot.create_list(:card_scan, 2, scanned_at: Date.today - 1.month) }

    before do
      login_as(:admin)
    end

    scenario 'Accessing the index' do
      visit admin_card_scans_path

      expect(current_path).to eql(admin_card_scans_path)

      expect(page.all('#card_scans tbody tr').count).to eql(card_scans.count)
    end
  end

  context "logged in as a user" do
    before { login_as(:user) }

    scenario 'Accessing the index' do
      visit admin_card_scans_path

      expect(current_path).not_to eql(admin_card_scans_path)
      assert_flash_presence 'access_denied'
    end
  end

  context "not logged in" do
    scenario 'Accessing the index' do
      visit admin_card_scans_path

      expect(current_path).to eql(login_path)
    end
  end
end
