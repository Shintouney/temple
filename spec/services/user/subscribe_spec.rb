require 'rails_helper'

describe User::Subscribe do
  let(:subscription_plan) { FactoryBot.create(:subscription_plan, price_ati: 120, price_te: 100, taxes_rate: 20) }
  let(:user) { FactoryBot.create(:user, payment_mode: 'cb') }
  let(:activemerchant_credit_card) do
    FactoryBot.build(:activemerchant_credit_card, :valid)
  end

  let(:create_subscription_double) { double }
  let(:process_payment_double) { double }

  subject { User::Subscribe.new(user, subscription_plan, activemerchant_credit_card) }

  describe '#new' do
    context 'with an expired subscription_plan' do
      before { subscription_plan.expire_at = DateTime.now - 1.minute }

      specify { expect { subject }.to raise_error(ArgumentError) }
    end
  end

  describe '#user' do
    it { expect(subject.user).to eql(user) }
  end

  describe '#subscription_plan' do
    it { expect(subject.subscription_plan).to eql(subscription_plan) }
  end

  describe '#subscription' do
    it { expect(subject.subscription).to be_nil }
  end

  describe '#order' do
    it { expect(subject.order).to be_nil }
  end

  describe '#activemerchant_credit_card' do
    it { expect(subject.activemerchant_credit_card).to eql(activemerchant_credit_card) }
  end

  describe '#execute' do

    context 'with a failed subscription creation' do
      before do
        Invoice::Charge.should_not_receive(:new)
        Subscription::Create.should_receive(:new).and_return(create_subscription_double)
        create_subscription_double.should_receive(:execute).once.with(no_args).and_return(false)
      end

      it 'does not create a user and subscription record' do
        emails_count = email_queue.size
        subscriptions_count = Subscription.count

        subject.execute

        expect(Subscription.count).to eql(subscriptions_count)

        expect(email_queue.size).to eql emails_count
      end
    end

    context 'with a successful payment' do
      before { VCR.insert_cassette 'user subscription payment success' }
      after { VCR.eject_cassette 'user subscription payment success' }

      it "creates a user with credit card and subscription record to assign to the order" do
        emails_count = email_queue.size

        subscriptions_count = Subscription.count

        subject.execute

        expect(user).to be_persisted

        expect(user.paybox_user_reference).to eql "TEMPLE#test##{ sprintf('%05d', user.id) }##{ user.created_at.to_time.to_i }"

        expect(user.current_credit_card.to_activemerchant).not_to be_nil
        expect(user.current_credit_card).not_to be_nil
        expect(user.credit_cards).not_to be_empty

        expect(Subscription.count).to eql(subscriptions_count + 1)

        last_subscription = Subscription.last
        expect(subject.subscription).to eql(last_subscription)
        expect(last_subscription.start_at).to eql(Date.today)
        expect(last_subscription.state).to eql('running')
        expect(last_subscription.subscription_plan).to eql(subject.order.order_items.first.product)
        expect(last_subscription.discount_period).to eql(subject.order.order_items.first.product.discount_period)
        expect(last_subscription.commitment_period).to eql(subject.order.order_items.first.product.commitment_period)

        expect(user.invoices.count).to eql 2
        expect(user.invoices.first).to be_paid
        expect(user.reload.invoices.first.total_price_ati).to eql 120

        expect(user.invoices.first.payments.first.price).to eql 120

        expect(user.invoices.last).to be_open
        expect(user.invoices.last.order_items).to be_empty
        expect(user.current_deferred_invoice).to eql user.invoices.last

        expect(email_queue.size).to eql emails_count + 1
      end

      it 'creates a current invoice' do
        expect(user.current_deferred_invoice).to be_nil

        subject.execute

        expect(user.reload.current_deferred_invoice).not_to be_nil
      end
    end

    context 'with a failed payment' do
      before { VCR.insert_cassette 'user subscription payment fail' }
      after { VCR.eject_cassette 'user subscription payment fail' }

      it 'does not create a user and subscription record' do
        emails_count = email_queue.size

        deffered_invoice = double('Invoice::Deferred::Create.new(user.reload)')
        Invoice::Deferred::Create.should_receive(:new).with(user) { deffered_invoice }
        deffered_invoice.should_receive(:execute)

        expect { subject.execute }.not_to change { Subscription.count }

        expect(email_queue.size).to eql emails_count
      end
    end
  end
end