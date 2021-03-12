require 'acceptance/acceptance_helper'

feature 'Admin credit card management' do
  let!(:user) { FactoryBot.build(:user, :with_registered_credit_card) }

  before do
    FactoryBot.create(:subscription, user: user, state: 'running')
  end

  context "logged in as an admin" do
    before { login_as(:admin) }

    scenario "Accessing the user's credit card admin edit view" do
      visit edit_admin_user_credit_card_path(user)

      expect(current_path).to eql(edit_admin_user_credit_card_path(user))

      expect(page).to have_content('John Doe')
      expect(page).to have_content('xxxxxxxxxxxx1293')
      expect(page).to have_content('06 / 2016')
      expect(page).not_to have_content('visa')
      expect(page).not_to have_content('772')
    end

    context 'when already has a CB' do
      let!(:credit_card) { FactoryBot.create :credit_card, :valid, :registered, user: user }

      scenario "Editing the user's credit card", vcr: { :cassette_name => "user_credit_card_update_success" } do
        visit edit_admin_user_credit_card_path(user)

        fill_in_credit_card_form

        expect(current_path).to eql(edit_admin_user_credit_card_path(user))

        expect(page).to have_content('Johnny Donny')
        expect(page).to have_content('xxxxxxxxxxxx4444')
        expect(page).to have_content("#{2.months.from_now.month} / #{2.years.from_now.year}")
        expect(page).not_to have_content('bogus')

        assert_flash_presence 'admin.credit_cards.update.notice'
      end
    end

    context 'when neither CB nor SEPA yet on new subscription.' do
      let!(:subscription) { FactoryBot.create(:subscription) }
      let!(:other_user) { subscription.user }

      before do
        other_user.update_attributes payment_mode: 'cb'
      end

      scenario "Add the first credit card", vcr: { cassette_name: 'paybox_add_cb' } do
        visit edit_admin_user_credit_card_path(other_user)
        expect(current_path).to eql(edit_admin_user_credit_card_path(other_user))

        fill_in_credit_card_form

        expect(current_path).to eql(edit_admin_user_credit_card_path(other_user))

        expect(other_user.subscriptions.last).not_to be nil
        expect(other_user.subscriptions.last.state).to eql('running')
        expect(other_user.invoices.size).to eql(2)
        expect(other_user.orders.size).to eql(1)
        expect(other_user.invoices.first.state).to eql('paid')
        expect(other_user.invoices.last.state).to eql('open')
        expect(other_user.invoices.first.total_price_ati).not_to be nil
        expect(other_user.invoices.first.total_price_ati).to eql(other_user.orders.last.order_items.to_a.sum(&:product_price_ati))
        expect(Payment.last.user_id).to eql(other_user.id)
      end
    end

    scenario "Failing to edit a user's credit card", vcr: { :cassette_name => "user_credit_card_update_failure" } do
      visit edit_admin_user_credit_card_path(user)

      choose I18n.t('bogus', scope: 'activemerchant.credit_card.brand')
      fill_in 'credit_card_first_name', with: 'Johnny'
      fill_in 'credit_card_last_name', with: 'Donny'
      fill_in 'credit_card_number', with: '111122223333777777777'
      select 2.months.from_now.month, from: 'credit_card_month'
      select 2.years.from_now.year, from: 'credit_card_year'
      fill_in 'credit_card_verification_value', with: 'ABCDEF'

      click_button 'credit_card_submit'

      expect(current_path).to eql(admin_user_credit_card_path(user))

      assert_flash_presence 'admin.credit_cards.update.alert'
    end
  end

  context "logged in as a user" do
    before { login_as(:user) }

    scenario 'Accessing the index' do
      visit edit_admin_user_credit_card_path(user)

      expect(current_path).to eql(account_root_path)
    end
  end

  context "not logged in" do
    scenario 'Accessing the index' do
      visit edit_admin_user_credit_card_path(user)

      expect(current_path).to eql(login_path)
    end
  end
end
