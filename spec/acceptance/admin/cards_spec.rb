require 'acceptance/acceptance_helper'

feature 'Admin User Card Management' do
  let!(:user_1) { FactoryBot.create(:user, card_reference: '123456789ABDEF11') }
  let!(:user_2) { FactoryBot.create(:user, card_reference: '123456789ABDEF12') }

  context "logged in as an admin" do
    before { login_as(:admin) }

    scenario 'Adding a card reference to a user' do
      ResamaniaApi::PushUserWorker.should_receive(:perform_async).with(user_1.id).once

      visit edit_admin_user_card_path(user_1)

      expect(find('#user_card_reference').value).to eql '123456789ABDEF11'

      fill_in 'user_card_reference', with: '123456789ABDEF13'
      click_button 'user_card_submit'

      expect(current_path).to eql edit_admin_user_card_path(user_1)
      assert_flash_presence 'admin.cards.update.notice'
      expect(find('#user_card_reference').value).to eql '123456789ABDEF13'
    end

    scenario "Adding a blank card reference to a user" do
      visit edit_admin_user_card_path(user_1)

      fill_in 'user_card_reference', with: ''
      click_button 'user_card_submit'

      expect(current_path).to eql admin_user_card_path(user_1)

      flash_message = I18n.t('flash.admin.cards.update.card_blank_alert')

      expect(page.find("#flash")).to have_text(flash_message)
    end

    scenario 'Adding an existing card reference to a user' do
      visit edit_admin_user_card_path(user_1)

      expect(find('#user_card_reference').value).to eql '123456789ABDEF11'

      fill_in 'user_card_reference', with: '123456789ABDEF12'
      click_button 'user_card_submit'

      expect(current_path).to eql admin_user_card_path(user_1)

      expect(page.find("#flash")).to have_text(user_2.lastname)
      expect(find('#user_card_reference').value).to eql '123456789ABDEF11'
    end

    scenario 'Adding an invalid card reference to a user' do
      visit edit_admin_user_card_path(user_1)

      fill_in 'user_card_reference', with: 'INVALID'
      click_button 'user_card_submit'

      assert_flash_presence 'admin.cards.update.alert'
    end

    scenario 'Deleting a user card reference' do
      ResamaniaApi::PushUserWorker.should_receive(:perform_async).with(user_2.id).once

      visit edit_admin_user_card_path(user_2)

      expect(find('#user_card_reference').value).to eql '123456789ABDEF12'

      click_link 'delete_user_card'

      expect(current_path).to eql edit_admin_user_card_path(user_2)
      assert_flash_presence 'admin.cards.destroy.notice'
      expect(find('#user_card_reference').value).to be_nil
    end

    scenario 'Printing a user card reference' do
      visit edit_admin_user_card_path(user_2)

      click_link 'print_user_card'

      expect(page.response_headers["Content-Type"]).to include("application/pdf")
      expect(page.status_code).to eql 200
    end

    scenario 'Forcing authorization on an authorized user card' do
      visit edit_admin_user_card_path(user_1)

      expect(page).not_to have_css('#force_authorization_user_card')
    end

    context 'with a user with a forbidden card' do
      let(:forbidden_user) { FactoryBot.create(:user, card_reference: 'FAFAFAFAFAFAFAFA', card_access: :forbidden) }

      scenario 'Forcing authorization on a user card' do
        ResamaniaApi::PushUserWorker.should_receive(:perform_async).with(forbidden_user.id).once

        visit edit_admin_user_card_path(forbidden_user)

        click_link 'force_authorization_user_card'

        expect(current_path).to eql edit_admin_user_card_path(forbidden_user)

        assert_flash_presence 'admin.cards.force_authorization.notice'
        expect(page).not_to have_css('#force_authorization_user_card')
      end
    end
  end

  context "logged in as a user" do
    before { login_as(:user) }

    scenario 'Accessing the index' do
      visit edit_admin_user_card_path(user_1)

      expect(current_path).not_to eql(edit_admin_user_card_path(user_1))
      assert_flash_presence 'access_denied'
    end
  end
end
