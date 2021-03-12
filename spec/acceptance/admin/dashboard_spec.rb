require 'acceptance/acceptance_helper'

feature "Admin dashboard" do
  context "logged in as an admin" do
    let!(:visits) { FactoryBot.build_list(:visit, 3, :in_progress, user: nil) }
    let!(:ended_visits) { FactoryBot.create_list(:visit, 10) }
    let!(:decorated_visit) { visits.first.decorate }
    let(:user) { FactoryBot.create(:user, lastname: "Anderson") }

    before do
      ['Dr. Zoidberg', 'Nicholas Brody', 'Dexter Morgan'].each_with_index do |name, index|
        firstname, lastname = name.split
        user = FactoryBot.create(:user, firstname: firstname, lastname: lastname)
        FactoryBot.create(:subscription, state: 'running', user: user)

        visit = visits[index]
        visit.user = user
        visit.save!
      end

      login_as(:admin)
    end

    scenario 'Accessing the index' do
      visit admin_root_path

      expect(current_path).to eql(admin_root_path)

      expect(page.all('.dashboard-panel-user').count).to eql 3

      expect(page.body.index('Nicholas Brody')).to be > page.body.index('Dexter Morgan')
      expect(page.body.index('Dexter Morgan')).to be < page.body.index('Dr. Zoidberg')
    end

    scenario 'Clicking a user profile button' do
      visit admin_root_path

      find("##{decorated_visit.panel_id}").find('.user_profile').click

      expect(current_path).to eql admin_user_path(decorated_visit.user)
    end

    scenario 'Clicking a new user order button' do
      visit admin_root_path

      find("##{decorated_visit.panel_id}").find('.new_user_order').click

      expect(current_path).to eql new_admin_user_order_path(decorated_visit.user)
    end

    scenario 'Clicking a finish visit button', js: true do
      visit admin_root_path

      expect(page.body).to have_css("##{decorated_visit.panel_id}")

      find("##{decorated_visit.panel_id}").hover
      wait_for_ajax
      page.execute_script %($('.finish_visit').click())
      wait_for_ajax
      expect(decorated_visit.object.reload.ended_at).not_to be_nil
    end

    scenario 'Adding a visiting user', js: true do
      visits_count = Visit.count
      visible_visits_count = page.all('.user_visit').length

      visit admin_root_path

      page.execute_script "$('#visit_user_id').val('#{user.id}')"

      click_button 'add_user_submit'

      wait_for_ajax

      expect(page.all('.user_visit').length).to eql(visible_visits_count + 1)

      expect(Visit.count).to eql(visits_count + 1)
    end

    scenario 'Failing to add a visiting user', js: true do
      visit admin_root_path

      fill_in 'users_with_autocomplete', with: 'Bleh'

      click_button 'add_user_submit'

      expect(page).to have_css("#flash")
    end

    scenario 'Displaying card scans', js: true do
      card_scans = FactoryBot.create_list(:card_scan, 6, scanned_at: Time.now)

      visit admin_root_path

      expect(page.all('#card_scans_shortlog .card_scan_shortlog_item').length).to eql(card_scans.count)

      new_card_scan = FactoryBot.create(:card_scan, scanned_at: Time.now)

      page.execute_script "window.CardScansShortlogPoller.onPoll()"

      expect(page).to have_css("#card_scans_shortlog .card_scan_shortlog_item[data-card-scan-id='#{new_card_scan.id}']")
    end
  end

  context "logged in as a user" do
    before { login_as(:user) }

    scenario 'Accessing the index' do
      visit admin_root_path

      expect(current_path).not_to eql(admin_root_path)
      assert_flash_presence 'access_denied'
    end
  end

  context "not logged in" do
    scenario 'Accessing the index' do
      visit admin_root_path

      expect(current_path).to eql(login_path)
    end
  end
end
