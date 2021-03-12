require 'acceptance/acceptance_helper'

feature 'User unsubscription during first month', type: :feature do
  let(:subscription_plan) { FactoryBot.create(:subscription_plan, price_ati: 120, price_te: 100, taxes_rate: 20) }
  let(:user) { create_subscribed_user(subscription_plan) }
  let!(:product_1) { FactoryBot.create(:article, price_ati: 20.35) }
  let!(:product_2) { FactoryBot.create(:article, price_ati: 45.22) }

  before do
    Timecop.travel(2013, 5, 26, 14, 0, 0)

    user.update_attributes(password: 'testtest1', password_confirmation: 'testtest1', payment_mode: 'cb')
  end

  after { Timecop.return }

  scenario 'Unsubscribing a user', js: true do
    ### Order products for the user

    login_as(:admin)

    visit new_admin_user_order_path(user)

    page.find("[data-article-category-id='#{product_1.article_category_id}']").click
    page.find("[data-article-id='#{product_1.id}']").click
    page.find("[data-article-category-id='#{product_2.article_category_id}']").click
    page.find("[data-article-id='#{product_2.id}']").click
    click_button 'order_submit'

    ### Unsubscribe user

    visit edit_admin_user_subscription_path(user)

    click_link 'destroy_subscription'

    ### Log out admin

    visit logout_path

    ### Simulate payment at the end of month

    Timecop.travel(2013, 6, 26, 14, 0, 0)

    VCR.use_cassette 'payment success' do
      invoice = user.current_deferred_invoice
      Invoice::Deferred::Replace.execute
      Invoice::Deferred::Charge.new(invoice.reload).execute
    end

    ### Assert user account views

    login_user(user, 'testtest1')

    click_link I18n.t('layouts.account.sidebar.invoices')
    expect(current_path).to eql(account_invoices_path)

    expect(page.all('#account_invoices_table tbody tr').length).to eql(2)
    expect(page).to have_content('120,00 €')
    expect(page).to have_content('65,57 €')
  end
end
