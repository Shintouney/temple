require 'acceptance/acceptance_helper'

feature 'Admin users creation' do
  context "logged in as an admin" do
    before { login_as(:admin) }

    let!(:subscription_plan) { FactoryBot.create(:subscription_plan) }
    let(:user_attributes) { FactoryBot.attributes_for(:user) }

    scenario "Creating a user", js: true do
      VCR.use_cassette 'user subscription payment success' do
        users_count = User.count
        visit new_admin_user_path
        fill_in_new_user_form(user_attributes)
        # fill_in_payment_credit_card_form(user_attributes)
        click_button 'user_submit'
        assert_flash_presence 'admin.users.create.notice'
        created_user = User.order(:created_at).last
        expect(current_path).to eql(edit_admin_user_credit_card_path(created_user))
        expect(User.count).to eql(users_count + 1)
        expect(created_user.email).to eql(user_attributes[:email])
        expect(created_user.subscriptions.to_a.map(&:state)).to eql(['pending'])
      end
    end

    scenario "Creating a user with a sponsor", js: true do
      VCR.use_cassette 'user subscription payment success' do
        sponsor_user = FactoryBot.create(:user)
        visit new_admin_user_path
        fill_in 'sponsor_email', with: sponsor_user.email
        fill_in_new_user_form(user_attributes)
        # fill_in_payment_credit_card_form(user_attributes)
        click_button 'user_submit'
        assert_flash_presence 'admin.users.create.notice'
        created_user = User.order(:created_at).last
        expect(current_path).to eql(edit_admin_user_credit_card_path(created_user))
        expect(created_user.email).to eql(user_attributes[:email])
        expect(created_user.sponsor_id).to eql(sponsor_user.id)
      end
    end

    scenario "Failing to create a user with an invalid sponsor email", js: true do
      users_count = User.count
      visit new_admin_user_path
      fill_in_new_user_form(user_attributes)
      fill_in 'sponsor_email', with: 'invalid@email'
      click_button 'user_submit'
      assert_flash_presence 'subscription.payments.create.alert_sponsor_email_invalid'
      expect(find('#user_sponsor').value).to eql('invalid@email')
      expect(User.count).to eql(users_count)
    end

    scenario "Failing to create a user with incomplete form", js: true do
      visit new_admin_user_path
      fill_in 'user_email', with: 'fail'
      click_button 'user_submit'
      assert_flash_presence 'subscription.payments.create.alert_invalid_user'
    end
  end
end
