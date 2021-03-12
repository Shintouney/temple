require 'acceptance/acceptance_helper'

feature 'Admin invoices management' do
  context "logged in as an admin" do
    before { login_as(:admin) }

    let!(:user) { create_subscribed_user }

    scenario "Displaying the user invoices" do
      visit admin_user_path(user)
      click_link 'user_invoices_link'

      expect(page.all('#user_invoices_table tbody tr').length).to eql(2)
      expect(page).to have_content(I18n.t('admin.invoices.index.total_price_ati_will_be_computed'))
    end

    scenario "Displaying the user invoices, with a computed total price ati" do
      invoice = user.invoices.first
      invoice.update_attribute(:total_price_ati, 125.0)

      visit admin_user_path(user)
      click_link 'user_invoices_link'

      expect(page.all('#user_invoices_table tbody tr').length).to eql(2)
      expect(page).to have_content('125,00 €')
    end

    scenario "Access to payments of the invoice" do
      visit admin_user_path(user)
      click_link 'user_invoices_link'

      expect(page).to have_content(I18n.t('admin.invoices.index.see_payments'))

      click_link I18n.t('admin.invoices.index.see_payments')

      expect(page).to have_content(I18n.t('admin.invoices.payments.title'))
      expect(page.all('#payments_user_invoice_table tbody tr').length).to eql(1)
    end

    scenario 'Displaying a invoice details' do
      invoice = user.invoices.last

      visit admin_user_path(user)
      click_link 'user_invoices_link'
      click_link "show_invoice_#{invoice.id}"

      expect(page.response_headers["Content-Type"]).to include("application/pdf")
      expect(page.status_code).to eql(200)
    end

    scenario 'Displaying a refunded invoice details' do
      invoice = user.invoices.with_state(:paid).last
      invoice.refund!

      visit admin_user_path(user)
      click_link 'user_invoices_link'
      click_link "credit_note_invoice_#{invoice.id}"

      expect(page.response_headers["Content-Type"]).to include("application/pdf")
      expect(page.status_code).to eql(200)
    end

    scenario 'Canceling an invoice with :pending_payment state' do
      invoice = user.invoices.last
      invoice.update_attribute(:state, :pending_payment)

      visit admin_user_path(user)
      click_link 'user_invoices_link'
      click_link "cancel_invoice_#{invoice.id}"

      assert_flash_presence I18n.t('flash.admin.invoices.update.notice')
      expect(page).to have_content(I18n.t('activerecord.attributes.invoice.state/canceled'))
      invoice.reload
      expect(page).to have_css(".fa.fa-info-circle")
    end

    scenario 'Refunding an invoice with :paid state' do
      invoice = user.invoices.last
      invoice.update_attribute(:state, :paid)

      visit admin_user_path(user)
      click_link 'user_invoices_link'
      click_link "refund_invoice_#{invoice.id}"

      assert_flash_presence I18n.t('flash.admin.invoices.update.notice')
      expect(page).to have_content(I18n.t('activerecord.attributes.invoice.state/refunded'))
      invoice.reload
      expect(page).to have_css(".fa.fa-info-circle")
    end

    scenario 'Accept payment on an invoice with :pending_payment state' do
      invoice = user.invoices.last
      invoice.update_attribute(:state, :pending_payment)

      visit admin_user_path(user)
      click_link 'user_invoices_link'
      click_link "accept_payment_invoice_#{invoice.id}"

      assert_flash_presence I18n.t('flash.admin.invoices.update.notice')
      expect(page).to have_content(I18n.t('activerecord.attributes.invoice.state/paid'))
    end
  end

  context "logged in as a user" do
    before { login_as(:user) }

    scenario "Displaying the user invoices" do
      user = create_subscribed_user
      visit admin_user_invoices_path(user)

      expect(current_path).not_to eql(admin_user_invoices_path(user))
      assert_flash_presence 'access_denied'
    end
  end
end
