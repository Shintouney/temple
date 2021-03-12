require 'acceptance/acceptance_helper'

feature 'Admin orders management' do
  context "logged in as an admin" do
    before { login_as(:admin) }

    let!(:user) { create_subscribed_user }

    before do
      user.update_attributes payment_mode: 'cb'
    end

    scenario "Displaying the user orders" do
      visit admin_user_path(user)
      click_link 'user_orders_link'

      expect(page.all('#user_orders_table tbody tr').length).to eql(1)
    end

    scenario 'Displaying an order details' do
      order = user.orders.last

      visit admin_user_path(user)
      click_link 'user_orders_link'
      click_link "show_order_#{order.id}"

      expect(page).to have_text(order.id)
      expect(page.all('table#order_order_items tbody tr').length).to eql(1)
    end

    scenario "Trying to create an order without articles" do
      order_count = Order.count

      visit admin_user_path(user)
      click_link "new_order"

      click_button 'order_submit'

      assert_flash_presence 'admin.orders.create.alert_empty'

      expect(Order.count).to eql(order_count)
    end

    scenario "Creating an order with a deferred payment", js: true do
      product1 = FactoryBot.create(:article, price_ati: 24, price_te: 20, taxes_rate: 20)
      product2 = FactoryBot.create(:article, price_ati: 36, price_te: 30, taxes_rate: 20)

      order_count = Order.count

      visit admin_user_path(user)
      click_link "new_order"

      page.find("[data-article-category-id='#{product1.article_category_id}']").click
      page.find("[data-article-id='#{product1.id}']").click

      page.find("[data-article-category-id='#{product2.article_category_id}']").click
      page.find("[data-article-id='#{product2.id}']").click
      page.find("[data-article-id='#{product2.id}']").click

      expect(page.find('#basket_total')).to have_text('96')

      click_button 'order_submit'

      assert_flash_presence 'admin.orders.create.notice'
      expect(current_path).to eql(admin_user_path(user))

      expect(Order.count).to eql(order_count + 1)

      order = Order.last
      expect(order.invoice).not_to be_paid
      expect(order.order_items.count).to eql(3)
      expect(order.computed_total_price_ati).to eql(96.0)
    end

    scenario "Creating an order with a successful direct payment", js: true, vcr: { :cassette_name => "admin_user_order_success" } do
      user.current_credit_card.update_attributes!(paybox_reference: 'SLDLrcsLMPC')

      product1 = FactoryBot.create(:article, price_ati: 20)
      order_count = Order.count

      visit new_admin_user_order_path(user)

      page.find("[data-article-category-id='#{product1.article_category_id}']").click
      page.find("[data-article-id='#{product1.id}']").click

      check(Order.human_attribute_name(:direct_payment))

      click_button 'order_submit'

      assert_flash_presence 'admin.orders.create.notice'

      expect(Order.count).to eql(order_count + 1)

      order = Order.last
      expect(order.invoice).to be_paid
      expect(order.invoice.payments.last.price).to eql(20)
    end

    scenario "Creating an order with a successful direct payment from inactive user", js: true, vcr: { :cassette_name => "admin_user_order_success" } do
      user.current_subscription.cancel!
      user.current_credit_card.update_attributes!(paybox_reference: 'SLDLrcsLMPC')

      product1 = FactoryBot.create(:article, price_ati: 20)
      order_count = Order.count

      visit new_admin_user_order_path(user)

      page.find("[data-article-category-id='#{product1.article_category_id}']").click
      page.find("[data-article-id='#{product1.id}']").click

      click_button 'order_submit'

      assert_flash_presence 'admin.orders.create.notice'

      expect(Order.count).to eql(order_count + 1)

      order = Order.last
      expect(order.invoice).to be_paid
      expect(order.invoice.payments.last.price).to eql(20)
    end

    scenario "Creating an order with a failed direct payment", js: true, vcr: { :cassette_name => "admin_user_order_failure" } do
      user.current_credit_card.paybox_reference = 'fail'
      user.payment_mode = 'cb'
      user.save!
      product1 = FactoryBot.create(:article, price_ati: 20)
      order_count = Order.count

      visit new_admin_user_order_path(user)

      page.find("[data-article-category-id='#{product1.article_category_id}']").click
      page.find("[data-article-id='#{product1.id}']").click

      check(Order.human_attribute_name(:direct_payment))

      click_button 'order_submit'

      assert_flash_presence 'admin.orders.create.alert_payment_failed'

      expect(Order.count).to eql(order_count)
    end

    context 'for an inactive user' do
      let(:inactive_user) { FactoryBot.create(:user) }

      scenario 'Accessing the new order view, is possible but only on direct payment' do
        visit new_admin_user_order_path(inactive_user)

        expect(current_path).to eql new_admin_user_order_path(inactive_user)
        all('input[type=checkbox]').each do |checkbox|
          expect(checkbox).to be_checked
        end
      end
    end

    scenario "Cancelling an order with a deferred payment" do
      product1 = FactoryBot.create(:article, price_ati: 24, price_te: 20, taxes_rate: 20)
      product2 = FactoryBot.create(:article, price_ati: 36, price_te: 30, taxes_rate: 20)

      add_products = Invoice::AddArticles.new(user.current_deferred_invoice, [product1.id, product2.id])
      add_products.execute
      order = add_products.order

      order_count = Order.count

      visit admin_user_orders_path(user)

      expect(page.all("a[data-method='delete']").length).to eql(1)

      click_link "destroy_order_#{order.id}"

      assert_flash_presence 'admin.orders.destroy.notice'
      expect(current_path).to eql(admin_user_orders_path(user))

      expect(Order.count).to eql(order_count - 1)

      expect(user.current_deferred_invoice.reload.total_price_ati).to eql(0)
    end

    scenario "Trying to cancel an order with a paid invoice" do
      product1 = FactoryBot.create(:article, price_ati: 24, price_te: 20, taxes_rate: 20)
      product2 = FactoryBot.create(:article, price_ati: 36, price_te: 30, taxes_rate: 20)

      add_products = Invoice::AddArticles.new(user.current_deferred_invoice, [product1.id, product2.id])
      add_products.execute
      order = add_products.order

      order_count = Order.count

      visit admin_user_orders_path(user)

      order.invoice.wait_for_payment!

      click_link "destroy_order_#{order.id}"

      assert_flash_presence 'admin.orders.destroy.alert'
      expect(current_path).to eql(admin_user_orders_path(user))

      expect(Order.count).to eql(order_count)
    end
  end

  context "logged in as a user" do
    before { login_as(:user) }

    scenario 'Accessing an order details' do
      user = create_subscribed_user
      visit admin_user_order_path(user, user.orders.last)

      expect(current_path).not_to eql(admin_user_order_path(user, user.orders.last))
      assert_flash_presence 'access_denied'
    end
  end
end
