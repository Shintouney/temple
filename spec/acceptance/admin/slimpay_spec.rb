require 'acceptance/acceptance_helper'

feature 'Slimpay' do
  context "logged in as an admin" do
    before { login_as(:admin) }

    let!(:admin) { FactoryBot.create(:admin) }
    let!(:user) { FactoryBot.create :user, payment_mode: 'sepa' }
    let!(:mandate) do
      FactoryBot.create :mandate, user: user, slimpay_order_state: 'open.running',
                                    slimpay_rum: nil, slimpay_order_reference: '8b57a695-4bd6-11e5-a8f5-0744bb4e3cd4'
    end

    before do
      subscription = FactoryBot.create(:subscription, user: user)
      subscription.start!
    end

    scenario "destroy user's mandate", vcr: { cassette_name: 'simpay_destroy_temp_mandate' } do
      visit edit_admin_user_credit_card_path(user.id)
      expect(current_path).to eq(edit_admin_user_credit_card_path(user.id))
      expect(page).to have_content(I18n.t('slimpay.mandate.cancel_and_new_sepa'))

      find(:xpath, "//a[@href='#{destroy_pending_path(user.id)}']").click

      expect(current_path).to eq(edit_admin_user_credit_card_path(user.id))
      expect(user.mandates).to be_blank
      expect(user.reload.payment_mode).to eq 'cb'
    end
  end
end
