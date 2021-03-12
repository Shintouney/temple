require 'acceptance/acceptance_helper'

feature "Subscription plans" do

  context "Given existing subscription plans" do
    let!(:subscription_plans) do
      [
        FactoryBot.create(:subscription_plan, position: 1, displayable: true, name: 'Displayable plan 1'),
        FactoryBot.create(:subscription_plan, position: 2, displayable: true, name: 'Displayable plan 2')
      ]
    end

    let!(:hidden_subscription_plans) do
      [
        FactoryBot.create(:subscription_plan, position: 3, displayable: false, name: 'Hidden plan 1'),
        FactoryBot.create(:subscription_plan, position: 4, displayable: false, name: 'Hidden plan 1')
      ]
    end

    let!(:discounted_subsription_plan) do
      FactoryBot.create(:subscription_plan, :discounted, position: 5, name: 'Discounted plan', discounted_price_ati: 100.91)
    end

    let!(:expired_subsription_plan) do
      FactoryBot.create(:subscription_plan, position: 6, expire_at: DateTime.now - 1.month, name: 'Expired plan')
    end

    scenario "Accessing the subscription plans page" do
      visit subscription_plans_path

      expect(page.body).to have_text('Displayable plan 1')
      expect(page.body).to have_text('Displayable plan 2')
      expect(page.body).not_to have_text('Hidden plan 1')
      expect(page.body).not_to have_text('Hidden plan 2')
      expect(page.body).to have_text('Discounted plan')
      expect(page.body).not_to have_text('Expired plan')

      expect(page.body).to have_text('100,91 €')

      expect(page.body.index('Displayable plan 1')).to be < page.body.index('Displayable plan 2')
      expect(page.body.index('Displayable plan 2')).to be < page.body.index('Discounted plan')
    end

    scenario "Buying a subscription plan" do
      visit subscription_plans_path

      click_button "buy_subscription_plan_#{subscription_plans.first.id}"

      expect(current_path).to eql(new_subscription_payment_path)
    end

    context "with a subscription plan requiring a code" do
      let(:code) { 'ABCD' }
      let!(:subscription_plan) { FactoryBot.create(:subscription_plan, code: code) }

      scenario "Trying to buy without a code" do
        visit subscription_plans_path
        click_link "buy_subscription_plan_#{subscription_plan.id}"

        expect(current_path).to eql(subscription_plan_path(subscription_plan))

        click_button "buy_subscription_plan_#{subscription_plan.id}"

        assert_flash_presence 'subscription_plans.buy.alert'

        expect(current_path).not_to eql(new_subscription_payment_path)
      end

      scenario "Trying to buy with an invalid code" do
        visit subscription_plan_path(subscription_plan)

        fill_in 'subscription_plan_selection_validator_code', with: 'invalid'

        click_button "buy_subscription_plan_#{subscription_plan.id}"

        assert_flash_presence 'subscription_plans.buy.alert'
      end

      scenario "Buying the plan" do
        visit subscription_plan_path(subscription_plan)

        fill_in 'subscription_plan_selection_validator_code', with: code

        click_button "buy_subscription_plan_#{subscription_plan.id}"

        expect(current_path).to eql(new_subscription_payment_path)
      end
    end

    context "logged in as a user" do
      before { login_as(:user) }

      scenario 'Accessing the subscription plans page' do
        visit subscription_plans_path

        expect(current_path).to eql account_root_path
      end
    end

    context "logged in as an admin" do
      before { login_as(:admin) }

      scenario 'Accessing the subscription plans page' do
        visit subscription_plans_path

        expect(page.body).to have_text('Displayable plan 1')
        expect(page.body).to have_text('Displayable plan 2')
        expect(page.body).not_to have_text('Hidden plan 1')
        expect(page.body).not_to have_text('Hidden plan 2')

        expect(page.body.index('Displayable plan 1')).to be < page.body.index('Displayable plan 2')
      end
    end
  end
end
