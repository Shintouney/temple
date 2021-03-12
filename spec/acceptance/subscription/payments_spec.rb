require 'acceptance/acceptance_helper'

feature "Subscription payment", type: :feature do
  context "without a chosen subscription plan" do
    scenario "Accessing the payment page" do
      visit new_subscription_payment_path

      expect(current_path).to eql(subscription_plans_path)
    end
  end

  context "Given a chosen subscription plan" do
    let!(:subscription_plan) { FactoryBot.create(:subscription_plan, price_ati: 120, price_te: 100, taxes_rate: 20) }

    before do
      visit subscription_plans_path
      
      click_button "buy_subscription_plan_#{subscription_plan.id}"
    end

    scenario "Accessing the payment page" do
      visit new_subscription_payment_path

      expect(current_path).to eql(new_subscription_payment_path)
    end

    scenario "Trying to access the payment show page" do
      visit subscription_payment_path

      expect(current_path).to eql(new_subscription_payment_path)
    end

    scenario "Paying a subscription", js: true do
      VCR.use_cassette 'user subscription payment success' do

        user_attributes = FactoryBot.attributes_for(:user)
        users_count = User.count

        visit new_subscription_payment_path

        fill_in_new_user_form(user_attributes)
        fill_in_payment_credit_card_form(user_attributes)
        check 'terms_accepted'

        click_button 'user_submit'

        expect(current_path).to eql(subscription_payment_path)

        created_user = User.last
        expect(User.count).to eql(users_count + 1)
        expect(created_user.email).to eql(user_attributes[:email])
        expect(created_user.last_login_at).not_to be_nil

        user_order = Order.last
        expect(user_order.invoice).to be_paid
        expect(user_order.user).to eql(created_user)

        expect(created_user.invoices.count).to eql 2
        expect(created_user.invoices.first).to be_paid
        expect(created_user.invoices.first.total_price_ati).to eql 120

        expect(created_user.invoices.first.payments.first.price).to eql 120

        expect(created_user.invoices.last).to be_open
        expect(created_user.invoices.last.order_items).to be_empty

        expect(created_user.subscriptions.to_a.map(&:state)).to eql(['running'])

        expect(page).to have_css('.social-share-button-twitter')
        expect(page).to have_css('.social-share-button-facebook')
        expect(page).to have_css('.social-share-button-google_plus')
        find('.social-share-button-facebook').click
        expect(windows.size).to eql(2)

        expect(page).to have_text(I18n.t('subscription.payments.show.edit_profile'))

        click_link I18n.t('subscription.payments.show.account_link')
        expect(current_path).to eql(account_root_path)
      end
    end

    scenario "Paying a subscription with a sponsor", js: true do
      VCR.use_cassette 'user subscription payment success' do
        user_attributes = FactoryBot.attributes_for(:user)
        sponsor_user = FactoryBot.create(:user)

        visit new_subscription_payment_path

        fill_in 'sponsor_email', with: sponsor_user.email

        fill_in_new_user_form(user_attributes)
        fill_in_payment_credit_card_form(user_attributes)
        check 'terms_accepted'

        click_button 'user_submit'

        expect(current_path).to eql(subscription_payment_path)

        created_user = User.last
        expect(created_user.email).to eql(user_attributes[:email])
        expect(created_user.sponsor_id).to eql(sponsor_user.id)

        expect(created_user.invoices.count).to eql 2
        expect(created_user.invoices.first).to be_paid
        expect(created_user.invoices.first.total_price_ati).to eql 120

        expect(created_user.invoices.first.payments.first.price).to eql 120

        expect(created_user.invoices.last).to be_open
        expect(created_user.invoices.last.order_items).to be_empty
      end
    end

    scenario "Failing to pay a subscription with an invalid sponsor email", js: true do
      user_attributes = FactoryBot.attributes_for(:user)

      users_count = User.count
      subscriptions_count = Subscription.count

      visit new_subscription_payment_path

      fill_in_new_user_form(user_attributes)
      check 'terms_accepted'

      fill_in 'sponsor_email', with: 'invalid@email'

      click_button 'user_submit'

      assert_flash_presence 'subscription.payments.create.alert_sponsor_email_invalid'

      expect(find('#user_sponsor').value).to eql('invalid@email')

      expect(User.count).to eql(users_count)
      expect(Subscription.count).to eql(subscriptions_count)
    end

    scenario "Failing to pay a subscription with incomplete form", js: true do
      users_count = User.count

      visit new_subscription_payment_path

      fill_in 'user_email', with: 'fail'
      check 'terms_accepted'

      click_button 'user_submit'

      assert_flash_presence 'subscription.payments.create.alert_invalid_user'

      expect(User.count).to eql(users_count)
    end

    scenario "Failing to pay a subscription with an existing user email", js: true do
      user = create_subscribed_user(subscription_plan)
      users_count = User.count

      visit new_subscription_payment_path

      fill_in 'user_email', with: user.email
      click_button 'user_submit'
      check 'terms_accepted'

      assert_flash_presence 'subscription.payments.create.alert_existing_account'

      expect(User.count).to eql(users_count)
    end

    scenario "Failing to pay a subscription with an incomplete credit card form", js: true do
      user_attributes = FactoryBot.attributes_for(:user)
      users_count = User.count

      visit new_subscription_payment_path

      fill_in_new_user_form(user_attributes)

      fill_in 'user_credit_card_first_name', with: user_attributes[:firstname]
      fill_in 'user_credit_card_last_name', with: user_attributes[:lastname]
      fill_in 'user_credit_card_number', with: '123'

      check 'terms_accepted'

      click_button 'user_submit'

      assert_flash_presence 'subscription.payments.create.alert_invalid_credit_card'

      expect(User.count).to eql(users_count)
    end

    scenario "Failing to pay a subscription with payment capture failing", js: true do
      VCR.use_cassette 'user subscription payment fail' do
        user_attributes = FactoryBot.attributes_for(:user)
        users_count = User.count
        subscriptions_count = Subscription.count

        visit new_subscription_payment_path

        fill_in_new_user_form(user_attributes)
        fill_in_payment_credit_card_form(user_attributes)
        check 'terms_accepted'

        click_button 'user_submit'

        assert_flash_presence 'subscription.payments.create.alert_payment_failed'
        expect(find('#user_credit_card_number').value).not_to eql('4242424242424242')

        expect(User.count).to eql(users_count)
        expect(Subscription.count).to eql(subscriptions_count)
      end
    end

    scenario "Failing to pay a subscription with terms not accepted" do
      user_attributes = FactoryBot.attributes_for(:user)
      users_count = User.count
      subscriptions_count = Subscription.count

      visit new_subscription_payment_path

      fill_in_new_user_form(user_attributes)
      uncheck 'terms_accepted'

      click_button 'user_submit'

      assert_flash_presence 'subscription.payments.create.alert_terms_not_accepted'
      expect(find('#user_credit_card_number').value).not_to eql('4242424242424242')

      expect(User.count).to eql(users_count)
      expect(Subscription.count).to eql(subscriptions_count)
    end
  end

  context "Given an subscription plan with a sponsorship price" do
    let!(:subscription_plan) do
      FactoryBot.create(:subscription_plan, :with_sponsorship, taxes_rate: 20,
                         price_ati: 120, price_te: 100,
                         sponsorship_price_te: 10, sponsorship_price_ati: 12)
    end

    before do
      visit subscription_plans_path
      click_button "buy_subscription_plan_#{subscription_plan.id}"
    end

    scenario "Paying a subscription without a sponsor", js: true do
      VCR.use_cassette 'user subscription payment success' do
        user_attributes = FactoryBot.attributes_for(:user)

        visit new_subscription_payment_path

        expect(page).to have_content(subscription_plan.decorate.displayed_price_ati)

        fill_in_new_user_form(user_attributes)
        fill_in_payment_credit_card_form(user_attributes)
        check 'terms_accepted'

        click_button 'user_submit'

        expect(current_path).to eql(subscription_payment_path)

        created_user = User.last
        expect(created_user.email).to eql(user_attributes[:email])

        user_order = Order.last
        expect(user_order.computed_total_price_ati.to_d).to eql(subscription_plan.price_ati.to_d)

        expect(created_user.subscriptions.to_a.map(&:state)).to eql(['running'])

        expect(created_user.invoices.count).to eql 2
        expect(created_user.invoices.first).to be_paid
        expect(created_user.invoices.first.total_price_ati).to eql 120

        expect(created_user.invoices.first.payments.first.price).to eql 120

        expect(created_user.invoices.last).to be_open
        expect(created_user.invoices.last.order_items).to be_empty
      end
    end

    scenario "Paying a subscription with a sponsor", js: true do
      VCR.use_cassette 'user subscription payment success' do
        user_attributes = FactoryBot.attributes_for(:user)
        sponsor_user = FactoryBot.create(:user)

        visit new_subscription_payment_path

        expect(page).to have_content(subscription_plan.decorate.displayed_price_ati)

        fill_in 'sponsor_email', with: sponsor_user.email

        fill_in_new_user_form(user_attributes)
        fill_in_payment_credit_card_form(user_attributes)
        check 'terms_accepted'

        click_button 'user_submit'

        expect(current_path).to eql(subscription_payment_path)

        created_user = User.last
        expect(created_user.email).to eql(user_attributes[:email])
        expect(created_user.sponsor_id).to eql(sponsor_user.id)

        user_order = Order.last
        expect(user_order.computed_total_price_ati.to_d).to eql(subscription_plan.sponsorship_price_ati.to_d)

        expect(created_user.subscriptions.to_a.map(&:state)).to eql(['running'])

        expect(created_user.invoices.count).to eql 2
        expect(created_user.invoices.first).to be_paid
        expect(created_user.invoices.first.total_price_ati).to eql 12

        expect(created_user.invoices.first.payments.first.price).to eql 12

        expect(created_user.invoices.last).to be_open
        expect(created_user.invoices.last.order_items).to be_empty
      end
    end
  end

  context "logged in as a user" do
    before { login_as(:user) }

    scenario 'Accessing the payment page' do
      visit new_subscription_payment_path

      expect(current_path).to eql account_root_path
    end
  end

  context "logged in as an admin" do
    before { login_as(:admin) }

    scenario 'Accessing the payment page' do
      visit new_subscription_payment_path

      expect(current_path).to eql subscription_plans_path
    end
  end

  context 'CB one month later' do
    let!(:user) { create_subscribed_user }
    before do
      Timecop.travel(user.subscriptions.last.created_at.advance(months: 1))
    end
    after do
      Timecop.return
    end
    it 'CRON charges the subscription again.', vcr: { cassette_name: 'payment_1_month_later' } do
      expect(user.invoices.size).to eq(2)
      expect(user.payments.size).to eq(1)
      Invoice::Deferred::Replace.execute
      Invoice.pending.due.each do |invoice|
        Invoice::Deferred::Charge.new(invoice).execute
      end
      expect(user.invoices.size).to eq(3)
      expect(user.payments.size).to eq(2)
      expect(user.payments.last.price).to eq(user.subscriptions.last.subscription_plan.price_ati)
    end
  end

  context 'SEPA one month later' do
    let!(:user) { create_subscribed_user }
    let!(:mandate) { FactoryBot.create :mandate, user: user }
    before do
      Timecop.travel(user.subscriptions.last.created_at.advance(months: 1))
    end
    after do
      Timecop.return
    end
    it 'CRON charges the subscription again but through SEPA' do
      expect(user.invoices.size).to eq(2)
      expect(user.payments.size).to eq(1)

      slimpay_debit = double('Slimpay::DirectDebit.new')
      expect(Slimpay::DirectDebit).to receive(:new) { slimpay_debit }
      expect(slimpay_debit).to receive(:make_payment)
      expect(JSON).to receive(:parse).at_least(:once) { { 'executionStatus' => Payment::WAITING_TO_PROCESS } }

      expect_any_instance_of(Payment::Processor).to_not receive(:process_paybox_payment)

      Invoice::Deferred::Replace.execute
      Invoice.pending.due.each do |invoice|
        Invoice::Deferred::Charge.new(invoice).execute
      end
      expect(user.invoices.size).to eq(3)
      expect(user.payments.size).to eq(2)
      expect(user.payments.last.price).to eq(user.subscriptions.last.subscription_plan.price_ati)
    end
  end
end
