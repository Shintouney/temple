require 'rails_helper'

describe Invoice::Deferred::Close do
  subject { Invoice::Deferred::Close.new(invoice) }

  let(:user) { FactoryBot.create(:user, :with_registered_credit_card, current_subscription: subscription) }
  let(:invoice) { FactoryBot.create(:invoice, state: 'open', user: user) }
  let(:subscription) { FactoryBot.create(:subscription, state: 'running') }

  before { user.update_attribute(:current_deferred_invoice, invoice) }

  describe '#invoice' do
    it { expect(subject.invoice).to eql invoice }
  end

  describe '#user' do
    it { expect(subject.user).to eql invoice.user }
  end

  describe '#subscription' do
    it { expect(subject.subscription).to eql user.current_subscription }
  end

  describe '#new' do
    context 'with an non-open invoice' do
      let(:invoice) { FactoryBot.create(:invoice, state: 'paid') }

      it { expect { subject }.to raise_error { ArgumentError } }
    end
  end

  describe '#execute' do
    context 'with no running subscription' do
      let(:subscription) { FactoryBot.create(:subscription, state: 'canceled') }

      context 'with no orders' do
        it 'closes the open invoice' do
          expect(subject.execute).to be true
          expect(invoice.payment_not_needed?).to be true
        end

        it "remove the user's current deferred invoice" do
          expect { subject.execute }.to change { user.current_deferred_invoice }.to(nil)
        end

        it 'does not add an order with a subscription to the invoice' do
          expect { subject.execute }.not_to change { invoice.orders.count }
        end

        it 'forbids user access' do
          ResamaniaApi::PushUserWorker.should_receive(:perform_async).with(user.id).once

          subject.execute

          expect(user.reload.card_access).to be_forbidden
        end
      end

      context 'with an order' do
        let!(:order_items) do
          FactoryBot.create_list(:order_item,
                                  6,
                                  order: order,
                                  product: article,
                                  product_price_ati: 2874.88,
                                  product_price_te: 2725,
                                  product_taxes_rate: 5.5,
                                  product_name: "Test product")
        end
        let(:order) { FactoryBot.create(:order) }
        let(:article) { FactoryBot.create(:article) }

        before do
          invoice.orders = [order.reload]
          invoice.save!
        end

        it 'closes the open invoice' do
          expect(subject.execute).to be true
          expect(invoice.pending_payment?).to be true
        end

        it "remove the user's current deferred invoice" do
          expect { subject.execute }.to change { user.current_deferred_invoice }.to(nil)
        end

        it 'does not add an order with a subscription to the invoice' do
          expect { subject.execute }.not_to change { invoice.orders.count }
        end

        it 'forbids user access' do
          ResamaniaApi::PushUserWorker.should_receive(:perform_async).with(user.id).once

          subject.execute

          expect(user.reload.card_access).to be_forbidden
        end
      end
    end

    context 'with a running subscription' do
      it 'closes the open invoice' do
        expect(subject.execute).to be true
        expect(invoice.pending_payment?).to be true
      end

      it "remove the user's current deferred invoice" do
        expect { subject.execute }.to change { user.current_deferred_invoice }.to(nil)
      end

      it 'creates a subscription plan order' do
        expect { subject.execute }.to change { invoice.orders.count }.by(1)
        expect(invoice.orders.last.order_items.first.product).to be_a SubscriptionPlan
      end

      it 'does not forbid user access' do
        ResamaniaApi::PushUserWorker.should_not_receive(:perform_async)

        subject.execute

        expect(user.reload.card_access).to be_authorized
      end
    end

    context 'with a failed execution' do
      let(:create_from_subscription_double) { double }

      before do
        Order::CreateFromSubscription.should_receive(:new).with(subject.invoice, subject.subscription).and_return(create_from_subscription_double)
        create_from_subscription_double.should_receive(:execute).and_return(false)
      end

      it 'does not close the invoice' do
        subject.execute
        expect(invoice.state).to eql 'open'
      end

      it 'does not create a subscription plan order' do
        expect { subject.execute }.not_to change { invoice.orders.count }
      end

      it 'does not remove the user current deferred invoice' do
        expect(user.current_deferred_invoice).not_to be_nil
        expect { subject.execute }.not_to change { user.reload.current_deferred_invoice }
      end
    end

    context 'with non-running subscriptions' do
      let!(:subscription) { FactoryBot.create(:subscription, state: 'canceled', user: user) }
      let(:user) { FactoryBot.create(:user) }
      let(:invoice) { FactoryBot.create(:invoice, user: user) }

      before do
        user.update_attributes!(card_access: :authorized, current_deferred_invoice: invoice)
      end

      it 'does not create new invoices' do
        subject.execute

        expect(user.reload.current_deferred_invoice).to be_nil
      end
    end
  end
end
