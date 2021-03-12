require 'acceptance/acceptance_helper'

feature 'Ordering' do
  context 'Given some products', type: :feature do
    let!(:user) { create_subscribed_user }
    let!(:product_1) { FactoryBot.create(:article, price_ati: 20.35) }
    let!(:product_2) { FactoryBot.create(:article, price_ati: 45.22) }

    before do
      user.current_credit_card.update_attributes!(paybox_reference: 'SLDLrcsLMPC')
      user.update_attributes(password: 'testtest1', password_confirmation: 'testtest1', payment_mode: 'cb')
    end

    scenario "Creating an order for a user", js: true, vcr: { :cassette_name => "admin_user_order_success" } do
      login_as(:admin)

      visit new_admin_user_order_path(user)

      page.find("[data-article-category-id='#{product_1.article_category_id}']").click
      page.find("[data-article-id='#{product_1.id}']").click
      page.find("[data-article-category-id='#{product_2.article_category_id}']").click
      page.find("[data-article-id='#{product_2.id}']").click
      check(Order.human_attribute_name(:direct_payment))
      click_button 'order_submit'

      visit logout_path

      login_user(user, 'testtest1')

      click_link I18n.t('layouts.account.sidebar.invoices')

      expect(page.all('#account_invoices_table tbody tr').length).to eql(2)
      expect(page).to have_content('65,57 €')
    end
  end
end
