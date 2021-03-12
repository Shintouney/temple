require 'acceptance/acceptance_helper'

feature "Account invoices management" do
  context "logged in as a user" do
    let!(:user) { create_subscribed_user }

    let(:invoice) { user.invoices.order(:created_at).first }
    let(:failed_article_order) do
      Invoice::AddArticles.new(user.current_deferred_invoice, [FactoryBot.create(:article).id]).tap(&:execute).order
    end

    before do
      login_user(user, 'ABCD1234')

      fail_order_payment(failed_article_order, user)
    end

    scenario 'Accessing the index' do
      visit account_invoices_path

      expect(current_path).to eql(account_invoices_path)

      expect(page.all('#account_invoices_table tbody tr').length).to eql(1)

      expect(page).to have_content(invoice.created_at.year)
    end

    scenario 'Displaying a invoice as PDF' do
      visit account_invoice_path(invoice, format: 'pdf')

      expect(page.response_headers["Content-Type"]).to include("application/pdf")
      expect(page.status_code).to eql 200
    end

    scenario 'Displaying a refunded invoice details' do
      invoice = user.invoices.with_state(:paid).last
      invoice.refund!

      expect(invoice.refunded_at).not_to eql(nil)

      visit credit_note_account_invoice_path(invoice, format: 'pdf')

      expect(page.response_headers["Content-Type"]).to include("application/pdf")
      expect(page.status_code).to eql(200)
    end
  end

  context "logged in as an admin" do
    before { login_as(:admin) }

    scenario 'Accessing the index' do
      visit account_invoices_path

      expect(current_path).to eql(admin_root_path)
      assert_flash_presence 'access_unavailable'
    end
  end

  context "not logged in" do
    scenario 'Accessing the index' do
      visit account_invoices_path

      expect(current_path).to eql(login_path)
    end
  end
end
