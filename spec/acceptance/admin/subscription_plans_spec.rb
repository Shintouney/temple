require 'acceptance/acceptance_helper'

feature 'Admin SubscriptionPlan management' do
  context "logged in as an admin" do
    before { login_as(:admin) }

    let!(:subscription_plans) do
      [
        FactoryBot.create(:subscription_plan, position: 4, name: 'Plan 4'),
        FactoryBot.create(:subscription_plan, position: 1, name: 'Plan 1'),
        FactoryBot.create(:subscription_plan, position: 2, name: 'Plan 2'),
        FactoryBot.create(:subscription_plan, position: 3, name: 'Plan 3')
      ]
    end

    let(:subscription_plan_attributes) { FactoryBot.attributes_for(:subscription_plan) }

    scenario 'Accessing the index' do
      visit admin_subscription_plans_path

      expect(page).to have_text(subscription_plans.first.name)
      expect(page.all('table tbody tr').length).to eql(4)

      expect(page.body.index('Plan 1')).to be < page.body.index('Plan 2')
      expect(page.body.index('Plan 2')).to be < page.body.index('Plan 3')
      expect(page.body.index('Plan 3')).to be < page.body.index('Plan 4')
    end

    scenario 'Creating a subscription_plan', js: true do
      subscription_plans_count = SubscriptionPlan.count

      visit admin_subscription_plans_path
      click_link 'new_subscription_plan'

      fill_in 'subscription_plan_name', with: subscription_plan_attributes[:name]
      select('Moliere', :from => 'subscription_plan_locations')
      fill_in 'subscription_plan_price_ati', with: subscription_plan_attributes[:price_ati]
      fill_in 'subscription_plan_price_te', with: subscription_plan_attributes[:price_te]
      fill_in 'subscription_plan_taxes_rate', with: subscription_plan_attributes[:taxes_rate]
      fill_in 'subscription_plan_commitment_period', with: subscription_plan_attributes[:commitment_period]
      fill_in 'subscription_plan_code', with: subscription_plan_attributes[:code]
      fill_in 'subscription_plan_discount_period', with: subscription_plan_attributes[:discount_period]
      fill_in 'subscription_plan_discounted_price_te', with: subscription_plan_attributes[:discounted_price_te]
      fill_in 'subscription_plan_discounted_price_ati', with: subscription_plan_attributes[:discounted_price_ati]
      check 'subscription_plan_displayable'
      uncheck 'subscription_plan_favorite'
      click_button 'subscription_plan_submit'
      wait_for_ajax

      expect(current_path).to eql(admin_subscription_plans_path)
      assert_flash_presence 'admin.subscription_plans.create.notice'

      expect(SubscriptionPlan.count).to eql(subscription_plans_count + 1)
      expect(SubscriptionPlan.last.name).to eql(subscription_plan_attributes[:name])
    end

    scenario 'Failing to create a subscription_plan', js: true do
      subscription_plans_count = SubscriptionPlan.count

      visit admin_subscription_plans_path
      click_link 'new_subscription_plan'

      click_button 'subscription_plan_submit'
      wait_for_ajax

      expect(current_path).to eql(admin_subscription_plans_path)

      expect(SubscriptionPlan.count).to eql(subscription_plans_count)
    end

    scenario 'Editing a subscription_plan', js: true do
      new_name = "name2"

      visit edit_admin_subscription_plan_path(subscription_plans.first)

      fill_in 'subscription_plan_name', with: new_name
      click_button 'subscription_plan_submit'

      wait_for_ajax

      expect(current_path).to eql(admin_subscription_plans_path)
      assert_flash_presence 'admin.subscription_plans.update.notice'

      expect(subscription_plans.first.reload.name).to eql(new_name)
    end

    scenario 'deleting a subscription_plan', js: true do
      subscription_plan = SubscriptionPlan.first
      subscription_plan.subscriptions << FactoryBot.create(:subscription)
      subscription_plan.save

      visit admin_subscription_plans_path
      page.accept_confirm do
        click_link "disable_subscription_plan_#{subscription_plans.first.id}"
      end
      wait_for_javascript_alerts
      wait_for_ajax

      assert_flash_presence 'admin.subscription_plans.disable.notice'
      expect(page).not_to have_css("#disable_subscription_plan_#{subscription_plans.first.id}")
    end

    scenario 'fail to deleting a subscription_plan', js: true do
      subscription_plan = SubscriptionPlan.first
      subscription_plan.subscriptions << FactoryBot.create(:subscription)
      subscription_plan.update_attribute(:locations, nil)

      visit admin_subscription_plans_path
      page.accept_confirm do
        click_link "disable_subscription_plan_#{subscription_plan.id}"
      end
      wait_for_javascript_alerts
      wait_for_ajax

      assert_flash_presence 'admin.subscription_plans.disable.alert'
      expect(page).to have_css("#disable_subscription_plan_#{subscription_plan.id}")
    end

    scenario 'Failing to edit a subscription_plan', js: true do
      visit edit_admin_subscription_plan_path(subscription_plans.first)

      fill_in 'subscription_plan_price_ati', with: ''
      click_button 'subscription_plan_submit'
      wait_for_ajax

      assert_flash_presence 'admin.subscription_plans.update.alert'
      expect(page).to have_css("#edit_subscription_plan_#{subscription_plans.first.id}")
    end

    scenario 'Deleting a subscription_plan', js: true do
      visit admin_subscription_plans_path

      click_link "destroy_subscription_plan_#{subscription_plans.first.id}"
      wait_for_ajax

      expect(current_path).to eql(admin_subscription_plans_path)
      assert_flash_presence 'admin.subscription_plans.destroy.notice'

      expect(SubscriptionPlan.exists?(subscription_plans.first.id)).to be false
    end

    scenario 'Failing to delete a subscription_plan', js: true do
      visit admin_subscription_plans_path

      # Make the plan undeletable
      FactoryBot.create(:subscription, subscription_plan: subscription_plans.first)

      click_link "destroy_subscription_plan_#{subscription_plans.first.id}"
      wait_for_ajax

      expect(current_path).to eql(admin_subscription_plans_path)
      assert_flash_presence 'admin.subscription_plans.destroy.alert'
    end

    context 'with a SubscriptionPlan with Subscriptions' do
      before { FactoryBot.create(:subscription, subscription_plan: subscription_plans.first) }

      scenario 'Editing a subscription_plan' do
        visit edit_admin_subscription_plan_path(subscription_plans.first)

        assert_flash_presence 'admin.subscription_plans.edit.edit_limited'

        expect(find('#subscription_plan_price_ati')[:disabled]).to eql 'disabled'
        expect(find('#subscription_plan_locations')[:disabled]).to eql 'disabled'
        expect(find('#subscription_plan_price_te')[:disabled]).to eql 'disabled'
        expect(find('#subscription_plan_taxes_rate')[:disabled]).to eql 'disabled'
        expect(find('#subscription_plan_commitment_period')[:disabled]).to eql 'disabled'
        expect(find('#subscription_plan_code')[:disabled]).to eql 'disabled'
        expect(find('#subscription_plan_discounted_price_te')[:disabled]).to eql 'disabled'
        expect(find('#subscription_plan_discounted_price_ati')[:disabled]).to eql 'disabled'
        expect(find('#subscription_plan_sponsorship_price_te')[:disabled]).to eql 'disabled'
        expect(find('#subscription_plan_sponsorship_price_ati')[:disabled]).to eql 'disabled'
        expect(find('#subscription_plan_displayable')[:disabled]).to be_nil
        expect(find('#subscription_plan_favorite')[:disabled]).to be_nil
        expect(find('#subscription_plan_submit')[:disabled]).to be_nil
      end
    end
  end

  context "logged in as a user" do
    before { login_as(:user) }

    scenario 'Accessing the index' do
      visit admin_subscription_plans_path

      expect(current_path).not_to eql(admin_subscription_plans_path)
      assert_flash_presence 'access_denied'
    end
  end
end
