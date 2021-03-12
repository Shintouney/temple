require 'rails_helper'

describe User::ChangeSubscriptionPlan do
  subject { User::ChangeSubscriptionPlan.new(user, new_subscription_plan) }

  let(:subscription_plan) { FactoryBot.create(:subscription_plan) }
  let(:new_subscription_plan) { FactoryBot.create(:subscription_plan) }
  let(:user) { FactoryBot.create(:user) }

  let(:subscription_create_double) { double }

  describe '#user' do
    it { expect(subject.user).to eql user }
  end

  describe '#subscription_plan' do
    it { expect(subject.subscription_plan).to eql new_subscription_plan }
  end

  let(:other_user) { FactoryBot.create(:user) }

  before do
    user.current_credit_card = FactoryBot.create(:credit_card, :valid, :registered, user: user)
    user.save!
    subscribe_user(user, subscription_plan)
  end

  describe '#execute' do
    context 'when execution succeeds' do
      before { VCR.insert_cassette 'payment_success' }
      after { VCR.eject_cassette 'payment_success' }

      context 'with an active user' do
        it "changes the user's subscription plan" do
          old_subscription = user.subscriptions.with_state(:running).first

          expect(subject.execute).to be true
          user.reload

          expect(user.current_subscription).not_to eql old_subscription
          expect(user.current_subscription.subscription_plan).to eql new_subscription_plan
          expect(old_subscription.reload.state).to eql 'replaced'
        end

        it 'does not create a new invoice' do
          expect { subject.execute }.not_to change { user.current_deferred_invoice }
        end
      end

      context 'with an inactive user' do
        before do
          user.current_subscription.cancel!
          user.reload
        end

        context 'with a user with current deferred invoice' do
          it 'creates a running subscription' do
            expect(user.current_subscription).to be_nil

            subject.execute
            user.reload

            expect(user.current_subscription).not_to be_nil
            expect(user.current_subscription.subscription_plan).to eql new_subscription_plan
          end

          it 'does not create a new invoice' do
            expect { subject.execute }.not_to change { user.current_deferred_invoice }
          end
        end

        context 'without current deferred invoice' do

          # before do
          #   Timecop.travel(2010, 07, 14, 14, 00, 00)
          #   other_user.current_credit_card = FactoryBot.create(:credit_card, :valid, :registered, user: other_user)
          #   other_user.save!
          #   subscribe_user(other_user, subscription_plan)
          #   other_user.update_attributes!(current_deferred_invoice: nil)
          #   other_user.reload
          # end

          # after { Timecop.return }

          it 'creates a running subscription' do
            expect(other_user.current_subscription).to be_nil

            other_user.current_credit_card = FactoryBot.create(:credit_card, :valid, :registered, user: other_user)
            other_user.save!
            subscribe_user(other_user, new_subscription_plan)
            other_user.reload

            subject.execute
            other_user.reload

            expect(other_user.current_subscription).not_to be_nil
            expect(other_user.current_subscription.subscription_plan).to eql new_subscription_plan
          end

          it 'creates a new invoice' do
            Timecop.travel(2010, 07, 14, 14, 00, 00)
            other_user.current_credit_card = FactoryBot.create(:credit_card, :valid, :registered, user: other_user)
            other_user.save!
            subscribe_user(other_user, subscription_plan)
            other_user.reload
            Timecop.return

            subject.execute

            expect(other_user.current_deferred_invoice).to be_a Invoice
            expect(other_user.current_deferred_invoice.start_at).to eql Date.new(2010, 7, 14)
            expect(other_user.current_deferred_invoice.end_at).to eql Date.new(2010, 8, 13)
            expect(other_user.current_deferred_invoice.subscription_period_start_at).to eql Date.new(2010, 8, 14)
            expect(other_user.current_deferred_invoice.subscription_period_end_at).to eql Date.new(2010, 9, 13)
            expect(other_user.current_deferred_invoice.next_payment_at).to eql Date.new(2010, 8, 14)
          end
        end
      end
    end

    context 'when execution fails' do
      before do
        Subscription::Create.new(user, subscription_plan)
        Subscription::Create.should_receive(:new).and_return(subscription_create_double)
        subscription_create_double.should_receive(:execute).and_return(false)
      end

      context 'with an active user' do
        it "should not change the user's subscription plan" do
          old_subscription = user.subscriptions.with_state(:running).first

          expect(subject.execute).to be false

          expect(user.current_subscription).to eql(old_subscription)
          expect(user.current_subscription.state).to eql('running')
        end

        it 'should not create related records' do
          orders_count = Order.count
          subscriptions_count = Subscription.count
          invoices_count = Invoice.count
          payments_count = Payment.count

          subject.execute

          expect(Order.count).to eql orders_count
          expect(Subscription.count).to eql subscriptions_count
          expect(Invoice.count).to eql invoices_count
          expect(Payment.count).to eql payments_count
        end
      end

      context 'with an inactive user' do
        before do
          user.current_subscription.cancel!
          user.reload
        end

        it 'returns return false' do
          expect(subject.execute).to be false
        end

        it 'should not create related records' do
          orders_count = Order.count
          subscriptions_count = Subscription.count
          invoices_count = Invoice.count
          payments_count = Payment.count

          subject.execute

          expect(Order.count).to eql orders_count
          expect(Subscription.count).to eql subscriptions_count
          expect(Invoice.count).to eql invoices_count
          expect(Payment.count).to eql payments_count
        end
      end
    end
  end

  describe '#create_deferred_invoice' do
    specify do
      deffered = double("Invoice::Deferred::Create.new(user)")
      Invoice::Deferred::Create.should_receive(:new) { deffered }
      deffered.should_receive(:execute)
      subject.send(:create_deferred_invoice)
    end
  end
end
