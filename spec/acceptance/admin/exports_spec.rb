require 'acceptance/acceptance_helper'

feature 'Admin export', type: :feature do
  context "logged in as an admin" do
    before { login_as(:admin) }

    context 'with invoices and articles' do
      let!(:article) { FactoryBot.create(:article, price_ati: 263.75, price_te: 250.0, taxes_rate: 5.5) }
      let!(:invoices) { FactoryBot.create_list(:invoice, 3, created_at: Time.zone.now.advance(days: -2)) }

      before do
        invoices.each do |invoice|
          order = FactoryBot.build(:order, invoice: invoice)
          Order::AddProduct.new(order, article).execute
          order.save!
        end

        invoices.first.wait_for_payment!
        invoices.first.accept_payment!
        invoices.last.wait_for_payment!
        invoices.last.cancel!
      end

      scenario 'Accessing the invoices as CSV', js: true do
        visit admin_exports_path
        wait_for_ajax
        expect(page).not_to have_css('.progress-bar')
        click_button 'finished_invoices_export'
        expect(page).to have_css('.alert')
        wait_for_ajax
        #expect(page).to have_css('.progress-bar')
      end

      context 'when export already exist' do
        let!(:export) { FactoryBot.create :export, state: 'in_progress', subtype: 'finished' }
        scenario 'Accessing the invoices as CSV', js: true do
          visit admin_exports_path
          wait_for_ajax
          expect(page).not_to have_css('#finished_invoices_export')
        end
      end

      scenario 'Accessing the open invoices as CSV', js: true do
        visit admin_exports_path
        wait_for_ajax
        click_button 'unfinished_invoices_export'
        #expect(page).to have_css('.progress-bar')
      end

      scenario 'Accessing the refunded and canceled invoices as CSV', js: true do
        visit admin_exports_path
        wait_for_ajax
        click_button 'special_invoices_export'
        #expect(page).to have_css('.progress-bar')
      end

      scenario 'Accessing the payments export as CSV', js: true do
        visit admin_exports_path
        wait_for_ajax
        click_button 'debit_payments_export'
        #expect(page).to have_css('.progress-bar')
      end

      context 'when existing file to download', js: true do
        let!(:export) { FactoryBot.create :export, subtype: "finished", export_type: "invoice", state: 'completed', date_start: Date.parse('2016-01-26') }
        let(:download_file_path) { Rails.root.join("spec", "fixtures", "transactions-finished-2016-01-26.csv") }
        let(:download_file_io) { File.open(download_file_path, 'rb') }

        after do
          download_file_io.close
        end

        scenario 'can download invoices', js: true do
          allow_any_instance_of(Export).to receive(:path).and_return(download_file_path)
          visit admin_exports_path
          wait_for_ajax
          click_link "dl_finished"
          expect(download_file_io.read.force_encoding(Encoding::UTF_8)).to include('154,17 €')
        end
      end
    end

    context 'with articles' do
      
      scenario 'Accessing the order items list as CSV', js: true do
        order_item = FactoryBot.create(:order_item, :validated, :from_article)
        visit admin_exports_path
        click_link 'articles_export'

        expect(page.response_headers['Content-Type']).to include('text/csv')
        expect(page.response_headers['Content-Disposition']).to include(".csv")

        expect(page.source).to include(order_item.product_name)
        expect(page.source).to include(order_item.order.user.firstname)
        expect(page.source.split("\n").length).to eql(2)
      end
    end

    context 'with active and inactive users' do
      let!(:active_users) { [create_subscribed_user, create_subscribed_user, create_subscribed_user] }
      let!(:inactive_users) { FactoryBot.create_list(:user, 4, lastname: 'TEST') }

      before do
        inactive_users.each do |ina_user|
          subscription = FactoryBot.create(:subscription, user_id: ina_user.id, state: 'canceled')
          ina_user.subscriptions << subscription
          ina_user.save!
        end
      end

      scenario 'Accessing the active users list as CSV', js: true do
        visit admin_exports_path
        click_button 'active_users_export'
        click_link 'dl_active'

        expect(page.response_headers['Content-Type']).to include('text/csv')
        expect(page.response_headers['Content-Disposition']).to include(".csv")

        expect(page.source).to include(active_users.first.firstname)
        expect(page.source).not_to include(inactive_users.first.firstname)
        expect(page.source.split("\n").length).to eql(4)
      end

      scenario 'Accessing the inactive users list as CSV', js: true do
        visit admin_exports_path
        click_button 'inactive_users_export'
        click_link 'dl_inactive'

        expect(page.response_headers['Content-Type']).to include('text/csv')
        expect(page.response_headers['Content-Disposition']).to include(".csv")

        expect(page.source).to include(inactive_users.first.firstname)
        expect(page.source).not_to include(active_users.first.firstname)
        expect(page.source.split("\n").length).to eql(5)
      end

      context 'When red list users exists' do
        let!(:red_list_users) { [create_subscribed_user, create_subscribed_user] }

        before do
          red_list_users.each do |red_user|
            invoice = FactoryBot.create(:invoice, created_at: Time.zone.now.advance(days: -2), state: 'pending_payment', user_id: red_user.id)
            red_user.invoices << invoice
          end
        end

        scenario 'Export red list users as CSV', js: true do
          visit admin_exports_path
          click_link 'red_list_export'

          expect(page.response_headers['Content-Type']).to include('text/csv')
          expect(page.response_headers['Content-Disposition']).to include(".csv")

          expect(page.source).to include(red_list_users.first.email)
          expect(page.source).to include(red_list_users.last.email)
          expect(page.source).not_to include(inactive_users.first.email)
          expect(page.source).not_to include(active_users.first.email)
          expect(page.source.split("\n").length).to eql(3)
        end
      end
    end

    describe "export visits list." do
      let!(:visits) { FactoryBot.create_list(:visit, 4, started_at: Time.zone.now.advance(days: -1)) }
      scenario 'Accessing the visits list as CSV', js: true do
        visit admin_exports_path
        click_link 'visits_export'

        expect(page.response_headers['Content-Type']).to include('text/csv')
        expect(page.response_headers['Content-Disposition']).to include(".csv")

        expect(page.source).to include(visits.first.started_at.to_s)
        expect(page.source).to include(visits.last.ended_at.to_s)
        expect(page.source).to include(visits.first.user.email)
        expect(page.source).to include(visits.first.user.firstname)
        expect(page.source).to include(visits.last.user.email)
        expect(page.source).to include(visits.last.user.firstname)
        expect(page.source).to include(visits.last.started_at.to_s)
        expect(page.source).to include(visits.last.ended_at.to_s)
        expect(page.source.split("\n").length).to eql(5)
      end
    end

    describe "export subscriptions list." do
      let!(:subscriptions) { FactoryBot.create_list(:subscription, 2) }
      scenario 'Accessing the subscriptions list as CSV', js: true do
        visit admin_exports_path
        click_link 'subscriptions_export'

        expect(page.response_headers['Content-Type']).to include('text/csv')
        expect(page.response_headers['Content-Disposition']).to include(".csv")

        expect(page.source).to include(subscriptions.first.decorate.start_at.to_s)
        expect(page.source).to include(subscriptions.first.subscription_plan.name)
        expect(page.source).to include(subscriptions.first.user.email)
        expect(page.source).to include(subscriptions.first.user.firstname)
        expect(page.source).to include(subscriptions.last.user.firstname)
        expect(page.source).to include(subscriptions.last.subscription_plan.price_ati.to_s)
        expect(page.source.split("\n").length).to eql(3)
      end
    end
  end

  context "logged in as a user" do
    before { login_as(:user) }

    scenario 'Accessing the index' do
      visit admin_articles_path

      expect(current_path).not_to eql(admin_articles_path)
      assert_flash_presence 'access_denied'
    end
  end
end
