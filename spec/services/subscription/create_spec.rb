require 'rails_helper'

describe Subscription::Create do
  subject { Subscription::Create.new(user, subscription_plan) }
  let(:user) { FactoryBot.create(:user) }
  let(:subscription_plan) { FactoryBot.create(:subscription_plan, commitment_period: 4) }

  describe '#user' do
    it { expect(subject.user).to eql user }
  end

  describe '#subscription_plan' do
    it { expect(subject.subscription_plan).to eql subscription_plan }
  end

  describe '#subscription' do
    it { expect(subject.subscription).to be_nil }
  end

  describe '#execute' do
    context 'with no commitment period and no discount period' do
      it 'creates a subscription' do
        expect(subject.execute).to be true
        expect(subject.subscription.user).to eql user
        expect(subject.subscription.subscription_plan).to eql subscription_plan
        expect(subject.subscription.commitment_period).to eql 4
        expect(subject.subscription.discount_period).to eql 0
        expect(subject.subscription.start_at).to eql Date.today
        expect(subject.subscription).to be_persisted
      end
    end

    context 'with a discount period' do
      let(:subscription_plan) do
        FactoryBot.create(:subscription_plan, :with_sponsorship,
                           discount_period: 2,
                           sponsorship_price_ati: 48,
                           sponsorship_price_te: 40,
                           price_ati: 96,
                           price_te: 80)
      end

      it 'creates a subscription' do
        expect(subject.execute).to be true
        expect(subject.subscription.user).to eql user
        expect(subject.subscription.subscription_plan).to eql subscription_plan
        expect(subject.subscription.commitment_period).to eql 0
        expect(subject.subscription.discount_period).to eql 0
        expect(subject.subscription.start_at).to eql Date.today
        expect(subject.subscription).to be_persisted
      end

      context 'with a sponsor' do
        let(:sponsor) { FactoryBot.create(:user) }
        let(:user) { FactoryBot.create(:user, sponsor: sponsor) }

        it 'creates a subscription' do
          expect(subject.execute).to be true
          expect(subject.subscription.user).to eql user
          expect(subject.subscription.subscription_plan).to eql subscription_plan
          expect(subject.subscription.commitment_period).to eql 0
          expect(subject.subscription.discount_period).to eql 2
          expect(subject.subscription.start_at).to eql Date.today
          expect(subject.subscription).to be_persisted
        end
      end
    end
  end
end
