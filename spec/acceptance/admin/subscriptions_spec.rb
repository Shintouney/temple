require 'acceptance/acceptance_helper'

feature 'Admin User Subscription management' do
  context 'logged in as admin' do
    let!(:subscription_plan) { FactoryBot.create(:subscription_plan, name: 'Plan ABC') }

    before { login_as(:admin) }

    scenario 'Accessing the subscription edition' do
      user = create_subscribed_user
      visit edit_admin_user_subscription_path(user)

      expect(current_path).to eql(edit_admin_user_subscription_path(user))
    end

    scenario 'Restarting a suspended subscription' do
      user = create_subscribed_user
      user.current_subscription.restart_date = Date.tomorrow
      user.current_subscription.temporarily_suspend!
      visit edit_admin_user_subscription_path(user)

      click_link 'restart_subscription_now'

      assert_flash_presence 'admin.subscriptions.restart.notice'
      expect(current_path).to eql(edit_admin_user_subscription_path(user))
      user.current_subscription.reload
      expect(user.current_subscription.restart_date).to eql(Date.today)
    end

    scenario "Editing the user's subscription plan" do
      user = create_subscribed_user
      user.paybox_user_reference = 'TEMPLE#test#00004#1396356468'
      user.update_attributes!(paybox_user_reference: 'TEMPLE#test#00004#1396356468')
      user.reload

      visit edit_admin_user_subscription_path(user)

      select 'Plan ABC', from: 'subscription_plan_id'
      click_button 'user_subscription_plan_submit'

      assert_flash_presence 'admin.subscriptions.update.notice'
      expect(find('#current_subscription_plan')).to have_content subscription_plan.name
      expect(current_path).to eql(edit_admin_user_subscription_path(user))

      expect(user.subscriptions.with_state(:running).first.subscription_plan).to eql subscription_plan
    end

    context "when I already have a registered user" do
      before { Timecop.travel(Time.zone.now.advance(weeks: -2)) }
      after { Timecop.return }
      let!(:user) { create_subscribed_user }

      before do
        user.paybox_user_reference = 'TEMPLE#test#00004#1396356468'
        user.update_attributes!(paybox_user_reference: 'TEMPLE#test#00004#1396356468')
        user.reload
      end

      scenario "Go and see the subscription page" do
        visit edit_admin_user_subscription_path(user)
        expect(page.body).to have_css('#current_subscription_plan')
        expect(page.body).to have_css('#subscription_plan_id')
        expect(page.body).to have_css('#user_subscription_plan_submit')
      end

      scenario "Change a user's subscription plan", js: true do

        VCR.use_cassette 'user change subscription' do

          visit edit_admin_user_subscription_path(user)
          select 'Plan ABC', from: 'subscription_plan_id'
          page.accept_confirm do
            click_button 'user_subscription_plan_submit'
          end
          expect(user.subscriptions.to_a.sort_by(&:id).first.state).to eq('replaced')
          expect(user.current_subscription.start_at).to eq(user.subscriptions.to_a.sort_by(&:id).first.try(:start_at))
          expect(user.current_subscription.subscription_plan_id).not_to eq(user.subscriptions.to_a.sort_by(&:id).first.try(:subscription_plan_id))

          # TODO: timecop futur + launch task
          Timecop.travel(Time.zone.now.advance(months: 1)) do

          end
        end

      end
    end

    context 'with an inactive user' do
      scenario "Editing the user's subscription plan" do
        user = create_subscribed_user
        user.current_subscription.cancel!
        user.update_attributes!(paybox_user_reference: 'TEMPLE#test#00004#1396356468')
        user.reload

        visit edit_admin_user_subscription_path(user)

        select 'Plan ABC', from: 'subscription_plan_id'
        click_button 'user_subscription_plan_submit'

        assert_flash_presence 'admin.subscriptions.update.notice'
        expect(find('#current_subscription_plan')).to have_content subscription_plan.name
        expect(current_path).to eql(edit_admin_user_subscription_path(user))

        expect(user.current_subscription.subscription_plan).to eql subscription_plan
      end
    end

    scenario "Failing to edit the user's subscription plan", vcr: { cassette_name: 'payment_failure' } do
      user = create_subscribed_user
      user.current_subscription.cancel!
      user.update_attributes!(current_deferred_invoice: nil, payment_mode: 'cb')

      visit edit_admin_user_subscription_path(user)

      select 'Plan ABC', from: 'subscription_plan_id'
      click_button 'user_subscription_plan_submit'

      assert_flash_presence 'admin.subscriptions.update.alert'
      expect(find('#current_subscription_plan')).not_to have_content subscription_plan.name
      expect(current_path).to eql(admin_user_subscription_path(user))
    end

    scenario "Choosing the blank option" do
      user = create_subscribed_user
      user.paybox_user_reference = 'TEMPLE#test#00004#1396356468'

      visit edit_admin_user_subscription_path(user)

      click_button 'user_subscription_plan_submit'

      assert_flash_presence 'admin.subscriptions.update.alert'
      expect(find('#current_subscription_plan')).not_to have_content subscription_plan.name
      expect(current_path).to eql(admin_user_subscription_path(user))
    end

    scenario "canceling the user's subscription" do
      user = create_subscribed_user

      visit edit_admin_user_subscription_path(user)

      click_link('destroy_subscription')

      assert_flash_presence 'admin.subscriptions.destroy.notice'
      expect(find('#current_subscription_plan')).not_to have_content subscription_plan.name
      expect(current_path).to eql(edit_admin_user_subscription_path(user))
    end
  end

  context "logged in as a user" do
    before { login_as(:user) }

    scenario 'Accessing the subscription edition' do
      user = create_subscribed_user
      visit edit_admin_user_subscription_path(user)

      expect(current_path).not_to eql(edit_admin_user_subscription_path(user))
      assert_flash_presence 'access_denied'
    end
  end
end
