require 'acceptance/acceptance_helper'

feature 'User subscription', type: :feature do
  context "Given a chosen subscription plan" do
    let!(:subscription_plan) { FactoryBot.create(:subscription_plan, price_ati: 120, price_te: 100, taxes_rate: 20) }

    scenario 'Subscribing as a new user', js: true, vcr: { :cassette_name => 'user subscription payment success' } do
      visit subscription_plans_path
      click_button "buy_subscription_plan_#{subscription_plan.id}"

      expect(current_path).to eql(new_subscription_payment_path)

      user_attributes = FactoryBot.attributes_for(:user)
      fill_in_new_user_form(user_attributes)
      fill_in_payment_credit_card_form(user_attributes)
      check 'terms_accepted'
      click_button 'user_submit'

      expect(current_path).to eql(subscription_payment_path)

      click_link I18n.t('subscription.payments.show.account_link')
      expect(current_path).to eql(account_root_path)

      click_link I18n.t('layouts.account.sidebar.invoices')
      expect(current_path).to eql(account_invoices_path)

      expect(page.all('#account_invoices_table tbody tr').length).to eql(1)
      expect(page).to have_content('120,00 €')
    end
  end
end
