require 'acceptance/acceptance_helper'

feature 'Monthly payment', type: :feature do
  let(:subscription_plan) { FactoryBot.create(:subscription_plan, price_ati: 120, price_te: 100, taxes_rate: 20) }
  let(:user) { create_subscribed_user(subscription_plan) }

  context 'Failing payment after 3 months' do
    before do
      Timecop.travel(2013, 5, 26, 14, 0, 0)

      user.update_attributes(password: 'testtest1', password_confirmation: 'testtest1', payment_mode: 'cb')

      Timecop.travel(2013, 6, 26, 14, 0, 0)

      VCR.use_cassette 'payment success' do
        invoice = user.current_deferred_invoice
        Invoice::Deferred::Replace.execute
        Invoice::Deferred::Charge.new(invoice.reload).execute
      end

      Timecop.travel(2013, 7, 26, 14, 0, 0)

      VCR.use_cassette 'payment success' do
        invoice = user.reload.current_deferred_invoice
        Invoice::Deferred::Replace.execute
        Invoice::Deferred::Charge.new(invoice.reload).execute
      end

      Timecop.travel(2013, 8, 26, 14, 0, 0)

      VCR.use_cassette 'payment failure' do
        invoice = user.reload.current_deferred_invoice
        Invoice::Deferred::Replace.execute
        Invoice::Deferred::Charge.new(invoice.reload).execute
      end

      Timecop.travel(2013, 9, 10, 14, 0, 0)
    end

    after { Timecop.return }

    context 'succeeding the retry paiement' do
      before do
        VCR.use_cassette 'payment success' do
          Invoice::Deferred::Charge.new(user.current_deferred_invoice).execute
        end
      end

      scenario 'Accessing the invoices index' do
        login_user(user, 'testtest1')

        click_link I18n.t('layouts.account.sidebar.invoices')
        expect(current_path).to eql(account_invoices_path)

        expect(page.all('#account_invoices_table tbody tr').length).to eql(4)

        expect(page).to have_content('120,00 €')

        # TODO : expect(page).not_to have_content(Invoice.human_state_name(:pending_payment))
      end
    end

    context 'failing the retry paiement' do
      before do
        VCR.use_cassette 'payment failure' do
          Invoice::Deferred::Charge.new(user.current_deferred_invoice).execute
        end
      end

      scenario 'Accessing the invoices index' do
        login_user(user, 'testtest1')

        click_link I18n.t('layouts.account.sidebar.invoices')
        expect(current_path).to eql(account_invoices_path)

        expect(page.all('#account_invoices_table tbody tr').length).to eql(3)

        expect(page).to have_content('120,00 €')

        # TODO : expect(page).to have_content(Invoice.human_state_name(:pending_payment))
      end
    end
  end
end
