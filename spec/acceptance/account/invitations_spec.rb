require 'acceptance/acceptance_helper'

feature "User invitations" do
  context "logged in as a user" do
    let!(:user) { FactoryBot.build(:user, :with_registered_credit_card) }

    before do
      # Simulating a new subscription
      subscription_plan = FactoryBot.create(:subscription_plan)
      visit subscription_plans_path
      click_button "buy_subscription_plan_#{subscription_plan.id}"

      login_with(user)
      subscription = FactoryBot.create(:subscription, user: user)
      subscription.start!
    end

    scenario 'Booking a lesson', js: true do
      to = FactoryBot.attributes_for(:user)[:email]
      text = "Message text"

      visit subscription_payment_path

      page.find("#new_invitation").click

      expect(page).to have_css('.modal-body')

      fill_in 'invitation_form_to', with: to
      fill_in 'invitation_form_text', with: text

      expect(UserMailer).to receive_message_chain(:invite_friend, :deliver_later).with(user.id, to, text).with(no_args)

      page.execute_script "$('#invitation_submit').trigger('click')"

      expect(page).to have_css('#invitation_close')
    end

    scenario 'Failing to book a lesson', js: true do
      visit subscription_payment_path

      page.find("#new_invitation").click

      expect(page).to have_css('.modal-body')

      fill_in 'invitation_form_to', with: 'wrong'

      expect(UserMailer).not_to receive_message_chain(:invite_friend, :deliver_later).with(user.id, to, text).with(no_args)
  
      page.execute_script "$('#invitation_submit').trigger('click')"

      expect(page).to have_css('.has-error')
    end
  end
end
