require 'rails_helper'

describe Invoice::Deferred::Replace do
  describe '.execute' do
    context 'with open and due invoices' do
      let!(:invoices) { FactoryBot.create_list(:invoice, 5, state: 'open', next_payment_at: Date.yesterday) }

      it 'closes the invoices' do
        subject.execute

        invoices.each do |invoice|
          expect(invoice.reload).to be_payment_not_needed
        end
      end
    end

    context 'with invoices waiting for payment' do
      let!(:invoices) { FactoryBot.create_list(:invoice, 5, state: 'pending_payment', next_payment_at: Date.yesterday) }

      it 'does nothing' do
        subject.execute

        invoices.each do |invoice|
          expect(invoice.reload).to be_pending_payment
        end
      end
    end

    context 'with running subscriptions' do
      context 'with users without current deferred invoices' do
        let!(:subscriptions) do
          FactoryBot.create_list(:subscription, 5, state: 'running', user: FactoryBot.create(:user, current_deferred_invoice: nil))
        end

        it 'creates new invoices' do
          subject.execute

          subscriptions.each do |subscription|
            expect(subscription.user.reload.current_deferred_invoice).to be_a Invoice
          end
        end

        it 'does not forbid user access' do
          subject.execute

          subscriptions.each do |subscription|
            expect(subscription.user.reload.card_access).to be_authorized
          end
        end
      end

      context 'with users with current deferred invoices' do
        let!(:subscriptions) do
          FactoryBot.create_list(:subscription, 5, state: 'running', user: FactoryBot.create(:user, current_deferred_invoice: invoice))
        end
        let(:invoice) { FactoryBot.create(:invoice) }

        it 'raises an exception and does not create new invoices' do
          subject.execute

          subscriptions.each do |subscription|
            expect(subscription.user.reload.current_deferred_invoice).to eql invoice
          end
        end

        it 'does not forbid user access' do
          subject.execute

          subscriptions.each do |subscription|
            expect(subscription.user.reload.card_access).to be_authorized
          end
        end
      end
    end

    context 'with non-running subscriptions' do
      let!(:subscription) { FactoryBot.create(:subscription, state: 'canceled', user: user) }
      let(:user) { FactoryBot.create(:user) }
      let(:invoice) { FactoryBot.create(:invoice, state: 'open', user: user) }

      before do
        user.update_attributes!(card_access: :authorized, current_deferred_invoice: invoice)
      end

      it 'does not create new invoices' do
        subject.execute

        expect(user.reload.current_deferred_invoice).to be_nil
      end

      it 'forbids user access' do
        subject.execute

        expect(user.reload.card_access).to be_forbidden
      end
    end
  end
end
