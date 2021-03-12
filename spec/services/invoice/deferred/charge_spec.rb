require 'rails_helper'

describe Invoice::Deferred::Charge do
  subject { Invoice::Deferred::Charge.new(invoice) }

  let(:invoice) { FactoryBot.create(:invoice, user: user, orders: orders, state: 'open') }
  let(:orders) { FactoryBot.create_list(:order, 3, user: user) }
  let(:user) { FactoryBot.create(:user, :with_registered_credit_card, payment_mode: 'cb') }

  let(:delayer_double) { double }

  before do
    Order::AddProduct.new(orders[0], FactoryBot.create(:article, price_ati: 24, price_te: 20, taxes_rate: 20)).execute
    Order::AddProduct.new(orders[1], FactoryBot.create(:article, price_ati: 24, price_te: 20, taxes_rate: 20)).execute
    Order::AddProduct.new(orders[2], FactoryBot.create(:article, price_ati: 36, price_te: 30, taxes_rate: 20)).execute

    invoice.wait_for_payment!
  end

  describe '#invoice' do
    it { expect(subject.invoice).to eql invoice }
  end

  describe '#payment' do
    it { expect(subject.payment).to be_nil }
  end

  describe '#subscription' do
    it { expect(subject.subscription).to eql invoice.user.current_subscription }
  end

  describe '#user' do
    it { expect(subject.user).to eql invoice.user }
  end

  describe '#execute' do
    context 'on a first time payment' do
      context 'with a successful payment' do
        before { VCR.insert_cassette 'payment success' }
        after { VCR.eject_cassette 'payment success' }

        it 'sets invoice and payment as paid' do
          subject.execute
          expect(invoice).to be_paid
          expect(subject.payment).to be_accepted
        end

        it 'does not change the next payment date of the invoice' do
          expect { subject.execute }.not_to change { invoice.reload.next_payment_at }
        end

        context 'with a forbidden card' do
          before { user.update_attributes!(card_access: :forbidden) }

          it 'authorizes user access' do
            ResamaniaApi::PushUserWorker.should_receive(:perform_async).with(user.id).once

            subject.execute

            expect(user.card_access).to be_authorized
          end
        end
      end

      context 'with a failed payment' do
        before { VCR.insert_cassette 'payment failure' }
        after { VCR.eject_cassette 'payment failure' }

        it 'sets invoice and payment as unpaid' do
          subject.execute
          expect(invoice).not_to be_paid
          expect(subject.payment).to be_declined

          expect(subject.payment.price).to eql 84

          expect(invoice.reload.payments.first).to eql subject.payment
        end

        it 'sets the next payment date of the invoice' do
          next_payment_target = invoice.next_payment_at + 15.days
          subject.execute
          expect(invoice.reload.next_payment_at).to eql next_payment_target
        end

        it 'changes the invoice state to pending_payment_retry' do
          expect{ subject.execute }.to change{ invoice.state }.from('pending_payment').to('pending_payment_retry')
        end
      end
    end

    context 'retrying a payment' do
      before { invoice.wait_for_payment_retry! }

      context 'with a successful payment' do
        before { VCR.insert_cassette 'payment success' }
        after { VCR.eject_cassette 'payment success' }

        it 'sets invoice and payment as paid' do
          subject.execute
          expect(invoice).to be_paid
          expect(subject.payment).to be_accepted

          expect(subject.payment.price).to eql 84

          expect(invoice.reload.payments.first).to eql subject.payment
        end

        it 'does not change the next payment date of the invoice' do
          expect { subject.execute }.not_to change { invoice.reload.next_payment_at }
        end

        context 'with a forbidden card' do
          before { user.update_attributes!(card_access: :forbidden) }

          it 'authorizes user access' do
            ResamaniaApi::PushUserWorker.should_receive(:perform_async).with(user.id).once

            subject.execute

            expect(user.card_access).to be_authorized
          end
        end
      end

      context 'with a failed payment' do
        before { VCR.insert_cassette 'payment failure' }
        after { VCR.eject_cassette 'payment failure' }

        it 'sets invoice and payment as unpaid' do
          subject.execute
          expect(invoice).not_to be_paid
          expect(subject.payment).to be_declined

          expect(invoice.reload.payments.first).to eql subject.payment
        end

        it 'sets the next payment date of the invoice' do
          next_payment_target = invoice.next_payment_at + 15.days
          subject.execute
          expect(invoice.reload.next_payment_at).to eql next_payment_target
        end

        it 'sends a failed payment email to the admin' do
          message_delivery = instance_double(ActionMailer::MessageDelivery)
          expect(AdminMailer).to receive(:monthly_subscription_payment_retry_failed).with(any_args).and_return(message_delivery)
          allow(message_delivery).to receive(:deliver_later)

          subject.execute
        end

        it 'changes the invoice state to pending_payment' do
          expect{ subject.execute }.to change{ invoice.state }.from('pending_payment_retry').to('pending_payment')
        end

        context 'with an authorized card' do
          before { user.update_attributes!(card_access: :authorized) }

          it 'forbids user access' do
            ResamaniaApi::PushUserWorker.should_receive(:perform_async).with(user.id).once

            subject.execute

            expect(user.card_access).to be_forbidden
          end
        end

        context 'with a forced_authorized card' do
          before { user.update_attributes!(card_access: :forced_authorized) }

          it 'does not change user access' do
            ResamaniaApi::PushUserWorker.should_not_receive(:perform_async)

            subject.execute

            expect(user.card_access).to be_forced_authorized
          end
        end
      end
    end
  end
end
