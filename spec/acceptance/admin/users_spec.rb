require 'acceptance/acceptance_helper'

feature 'Admin users management', type: :feature do
  context "logged in as an admin" do
    before { login_as(:admin) }

    let!(:admin) { FactoryBot.create(:admin) }
    let!(:active_users) { FactoryBot.create_list(:user, 2) }
    let!(:inactive_users) { FactoryBot.create_list(:user, 2) }

    let!(:profile) { FactoryBot.create(:profile, user: active_users.first, boxing_level: :medium, fitness_goals: [:build_up]) }

    let(:user_attributes) { FactoryBot.attributes_for(:user) }

    before do
      active_users.each do |user|
        subscription = FactoryBot.create(:subscription, user: user)
        subscription.start!
      end

      inactive_users.each do |user|
        FactoryBot.create(:subscription, user: user)
      end
    end

    scenario 'Accessing the active index', js: true do
      visit active_admin_users_path
      wait_for_ajax
      expect(page).to have_text(active_users.first.email)
      expect(page).not_to have_text(admin.email)
      expect(page.all('table tbody tr').length).to eql(2)
    end

    scenario 'Accessing the active index as CSV' do
      visit active_admin_users_path(format: :csv)

      expect(page.response_headers['Content-Type']).to include('text/csv')
      expect(page.response_headers['Content-Disposition']).to include(".csv")

      expect(page.source).to include(active_users.first.email)
      expect(page.source).to include(active_users.first.profile.boxing_level.text)
      expect(page.source).to include(active_users.first.profile.fitness_goals.first.text)
      expect(page.source).not_to include(inactive_users.first.email)
      expect(page.source).not_to include(admin.email)
    end

    scenario 'Accessing the inactive index', js: true do
      visit inactive_admin_users_path
      wait_for_ajax
      expect(page).to have_text(inactive_users.first.email)
      expect(page).not_to have_text(admin.email)
      expect(page.all('table tbody tr').length).to eql(2)
    end

    scenario 'Accessing the inactive index as CSV' do
      visit inactive_admin_users_path(format: :csv)

      expect(page.response_headers['Content-Type']).to include('text/csv')
      expect(page.response_headers['Content-Disposition']).to include(".csv")

      expect(page.source).to include(inactive_users.first.email)
      expect(page.source).not_to include(active_users.first.email)
      expect(page.source).not_to include(admin.email)
    end

    scenario 'Accessing the suspended users index', js: true do
      user = active_users.first
      user.current_subscription.restart_date = Date.tomorrow
      user.current_subscription.temporarily_suspend!

      visit temporarily_suspended_users_admin_users_path
      wait_for_ajax
      expect(page).to have_text(active_users.first.email)
      expect(page).not_to have_text(admin.email)
      expect(page.all('table tbody tr').length).to eql(1)
    end

    context "when a user as unpaid invoices" do
      let!(:red_list_user) { active_users.first }
      let!(:invoice) { FactoryBot.create :invoice, user: red_list_user, state: 'pending_payment_retry', total_price_ati: '8.42' }
      let!(:payment) { FactoryBot.create :payment, user: red_list_user, state: 'declined', price: '8.42', comment: 'lorem ipsum' }

      before do
        invoice.payments << payment
      end

      scenario 'Accessing the red_list index', js: true do
        visit red_list_admin_users_path

        expect(User.red_list).not_to be_empty
        expect(User.red_list).to eq([red_list_user])

        expect(page.all('table#user-red-list-table thead').length).to eql(1)
        expect(page.all('table tbody').length).to eql(1)

        wait_for_ajax

        expect(page.all('table tbody tr').length).to eql(1)
        expect(page).to have_text(red_list_user.email)
        expect(page).to have_text('8.42')
      end
    end

    scenario 'Editing a user', js: true do
      new_email = "email2@example.org"
      visit active_admin_users_path

      wait_for_ajax

      click_link "edit_user_#{active_users.first.id}"

      fill_in 'user_email', with: new_email
      click_button 'user_submit'

      expect(current_path).to eql(admin_user_path(active_users.first))
      assert_flash_presence 'admin.users.update.notice'

      expect(active_users.first.reload.email).to eql(new_email)
    end

    scenario 'Failing to edit a user' do
      visit edit_admin_user_path(active_users.first)

      fill_in 'user_email', with: 'wrong'
      click_button 'user_submit'

      assert_flash_presence 'admin.users.update.alert'
      expect(page).to have_css("#edit_user_#{active_users.first.id}")
    end

    context "with a user that has an active subscription" do
      let(:subscription_plan) { FactoryBot.create(:subscription_plan) }
      let!(:user) { create_subscribed_user(subscription_plan) }

      scenario "Displaying a user details", js: true do
        visit active_admin_users_path

        click_link "show_user_#{user.id}"

        expect(current_path).to eql(admin_user_path(user))

        expect(page).to have_text(user.lastname)
        expect(page).to have_text(subscription_plan.name)
        expect(page.all('ul#user_orders_overview li').length).to eql(1)
        expect(page).to have_css('#force_access', visible: false)

        expect(page).to have_text(I18n.t("admin.users.show.no_authorize"))
        find(:xpath, '//input[@id="force_access"]/..').click
        expect(page).to have_text(I18n.t("admin.users.show.authorize"))
        find(:xpath, '//input[@id="force_access"]/..').click
        expect(page).to have_text(I18n.t("admin.users.show.no_authorize"))
      end

      scenario 'Set a origin location to maillot', js: true do
        visit active_admin_users_path
        click_link "show_user_#{user.id}"
        click_link "Maillot"
        expect(user.subscriptions.last.origin_location).to eql("maillot")
      end
      scenario 'Set a origin location to moliere', js: true do
        visit active_admin_users_path
        click_link "show_user_#{user.id}"
        click_link "Molière"
        expect(user.subscriptions.last.origin_location).to eql("moliere")
      end
      scenario 'Set a origin location to amelot', js: true do
        visit active_admin_users_path
        click_link "show_user_#{user.id}"
        click_link "Amelot"
        expect(user.subscriptions.last.origin_location).to eql("amelot")
      end
    end

    context "when admin forbid planning access to user" do
      let(:subscription_plan) { FactoryBot.create(:subscription_plan) }
      let!(:user) { FactoryBot.create :user, :with_mandate, :with_registered_credit_card }

      before do
        subscribe_user(user, subscription_plan)
      end

      scenario "Displaying a user details", js: true do
        visit admin_user_path(user)

        expect(page).to have_css('#forbid_access', visible: false)

        expect(page).to have_text(I18n.t("admin.users.show.authorize"))
        find(:xpath, '//input[@id="forbid_access"]/..').click
        expect(page).to have_text(I18n.t("admin.users.show.no_authorize"))
        find(:xpath, '//input[@id="forbid_access"]/..').click
        expect(page).to have_text(I18n.t("admin.users.show.authorize"))
      end
    end

    context 'when admin changes payment_mode' do
      let(:subscription_plan) { FactoryBot.create(:subscription_plan) }
      let!(:user) { FactoryBot.create :user, :with_mandate, :with_registered_credit_card, :with_mandate, payment_mode: 'sepa' }

      context 'when valid user' do
        before do
          subscribe_user(user, subscription_plan)
        end

        scenario 'Change payment_mode', js: true do
          Mandate.any_instance.should_receive(:refresh)
          visit edit_admin_user_credit_card_path(user)

          expect(page).to have_css('#payment_mode', visible: false)
          expect(page).to have_css('.btn.toggle.off')

          find(:xpath, '//input[@id="payment_mode"]/..').click
          wait_for_ajax

          expect(page).to have_css('.btn.toggle')
          expect(user.payment_mode).to match('sepa')
        end
      end

      context 'when bad user' do
        before do
          user.update_column :firstname, nil
          user.reload
        end
        scenario 'Change payment_mode return error', js: true do
          Mandate.any_instance.should_receive(:refresh)
          visit edit_admin_user_credit_card_path(user)

          expect(page).to have_css('#payment_mode', visible: false)

          expect(page).to have_css('.btn.toggle.off')

          find(:xpath, '//input[@id="payment_mode"]/..').click
          wait_for_ajax
          
          expect(page).to have_css('.btn.toggle')
        end
      end
    end
  end

  context "logged in as a user" do
    before { login_as(:user) }

    scenario 'Accessing the index' do
      visit active_admin_users_path

      expect(current_path).not_to eql(active_admin_users_path)
      assert_flash_presence 'access_denied'
    end
  end
end
