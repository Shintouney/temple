require 'rails_helper'

describe Order::CreateFromSubscription do
  let(:user) { FactoryBot.create(:user) }
  let(:subscription_plan) { FactoryBot.create(:subscription_plan) }
  let(:subscription) { FactoryBot.create(:subscription, subscription_plan: subscription_plan, user: user) }
  let(:invoice) { FactoryBot.create(:invoice, user: user) }

  subject { Order::CreateFromSubscription.new(invoice, subscription) }

  describe '#invoice' do
    it { expect(subject.invoice).to eql invoice }
  end

  describe '#subscription' do
    it { expect(subject.subscription).to eql subscription }
  end

  describe '#subscription_plan' do
    it { expect(subject.subscription_plan).to eql subscription_plan }
  end

  describe '#order' do
    it { expect(subject.order).to be_a Order }
  end

  describe '#user' do
    it { expect(subject.user).to eql user }
  end

  describe '#execute' do
    context 'with a discount period' do
      let(:subscription_plan_discount_period) { 3 }

      before do
        subscription.update_attributes! discount_period: subscription_plan_discount_period
      end

      context "with a discounted price on the subscription plan" do
        before do
          subscription_plan.update_attributes!(discounted_price_te: 400,
                                               discounted_price_ati: 480,
                                               discount_period: subscription_plan_discount_period)
        end

        it 'should add an order_item to the order with the subscription_plan discount prices' do
          previous_discount_period = subscription.discount_period

          subject.execute

          expect(subject.order.order_items.count).to eql(1)

          order_item = subject.order.order_items.last
          expect(order_item.product).to eql(subscription_plan)
          expect(order_item.product_name).to eql(subscription_plan.name)
          expect(order_item.product_price_te).to eql(subscription_plan.discounted_price_te)
          expect(order_item.product_price_ati).to eql(subscription_plan.discounted_price_ati)
          expect(order_item.product_taxes_rate).to eql(subscription_plan.taxes_rate)

          expect(subscription.reload.discount_period).to eql previous_discount_period - 1
        end
      end

      context "with a sponsorship price on the subscription plan" do
        before do
          subscription_plan.update_attributes!(sponsorship_price_te: 400,
                                               sponsorship_price_ati: 480,
                                               discount_period: subscription_plan_discount_period)
        end

        it 'should add an order_item to the order with the subscription_plan sponsorship prices' do
          previous_discount_period = subscription.discount_period

          subject.execute

          expect(subject.order.order_items.count).to eql(1)

          order_item = subject.order.order_items.last
          expect(order_item.product).to eql(subscription_plan)
          expect(order_item.product_name).to eql(subscription_plan.name)
          expect(order_item.product_price_te).to eql(subscription_plan.sponsorship_price_te)
          expect(order_item.product_price_ati).to eql(subscription_plan.sponsorship_price_ati)
          expect(order_item.product_taxes_rate).to eql(subscription_plan.taxes_rate)

          expect(subscription.reload.discount_period).to eql previous_discount_period - 1
        end
      end
    end

    context 'without a discount period' do
      let(:subscription_plan) { FactoryBot.create(:subscription_plan, :discounted) }

      it 'should add an order_item to the order with the subscription_plan full prices' do
        previous_discount_period = subscription.discount_period

        subject.execute

        expect(subject.order.order_items.count).to eql(1)

        order_item = subject.order.order_items.last
        expect(order_item.product).to eql(subscription_plan)
        expect(order_item.product_name).to eql(subscription_plan.name)
        expect(order_item.product_price_te).to eql(subscription_plan.price_te)
        expect(order_item.product_price_ati).to eql(subscription_plan.price_ati)
        expect(order_item.product_taxes_rate).to eql(subscription_plan.taxes_rate)

        expect(subscription.reload.discount_period).to eql previous_discount_period
      end
    end

    context 'with a commitment period' do
      let(:subscription_plan) { FactoryBot.create(:subscription_plan, commitment_period: 3) }

      before do
        subscription.commitment_period = subscription_plan.commitment_period
      end

      it 'should add an order_item to the order with subscription_plan commitment period and decrement it' do
        subject.execute

        expect(subject.order.order_items.count).to eql(1)

        order_item = subject.order.order_items.last
        expect(order_item.product).to eql(subscription_plan)
        expect(order_item.product_name).to eql(subscription_plan.name)
        expect(order_item.product_price_te).to eql(subscription_plan.price_te)
        expect(order_item.product_price_ati).to eql(subscription_plan.price_ati)
        expect(order_item.product_taxes_rate).to eql(subscription_plan.taxes_rate)

        expect(subscription.reload.commitment_period).to eql 2
      end
    end

    context 'without a commitment period' do
      let(:subscription_plan) { FactoryBot.create(:subscription_plan, commitment_period: 0) }

      before do
        subscription.commitment_period = subscription_plan.commitment_period
      end

      it 'should add an order_item to the order with subscription_plan commitment period' do
        subject.execute

        expect(subject.order.order_items.count).to eql(1)

        order_item = subject.order.order_items.last
        expect(order_item.product).to eql(subscription_plan)
        expect(order_item.product_name).to eql(subscription_plan.name)
        expect(order_item.product_price_te).to eql(subscription_plan.price_te)
        expect(order_item.product_price_ati).to eql(subscription_plan.price_ati)
        expect(order_item.product_taxes_rate).to eql(subscription_plan.taxes_rate)

        expect(subscription.reload.commitment_period).to eql 0
      end
    end

    context 'with a failed execution' do
      let(:subscription_plan) { FactoryBot.create(:subscription_plan, :discounted, commitment_period: 3) }

      before { subject.should_receive(:update_subscription_period_attributes).and_return(false) }

      it 'should not create an order' do
        expect { subject.execute }.not_to change { Order.count }
      end

      it 'should change the subscription discount period' do
        expect { subject.execute }.not_to change { subscription.discount_period }
      end

      it 'should change the subscription commitment period' do
        expect { subject.execute }.not_to change { subscription.commitment_period }
      end
    end
  end
end
