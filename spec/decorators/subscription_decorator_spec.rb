require 'rails_helper'

describe SubscriptionDecorator do
  let(:subscription_plan) { FactoryBot.create :subscription_plan, commitment_period: 12}

  subject { SubscriptionDecorator.decorate(FactoryBot.build(:subscription, subscription_plan: subscription_plan, commitment_period: 12)) }

  describe '#subscription_plan_name' do
    describe '#subscription_plan_name' do
      it { expect(subject.subscription_plan_name).to eql(subject.subscription_plan.name) }
    end
  end

  describe '#start_at' do
    before { subject.start_at = Time.new(2014, 1, 2, 10, 30) }

    describe '#start_at' do
      it { expect(subject.start_at).to match('2014') }
    end
  end

  describe '#commitment_period' do
    before { subject.created_at = Time.new(Date.today.year, Date.today.month, Date.today.day, 10, 30) }

    describe '#commitment_period' do
      it { expect(subject.commitment_period).to match("#{Date.today.year + 1}") }
    end
  end

  describe '#commitment_period_with_restart_date' do
    before do
      subject.created_at = Time.new(Date.today.year, Date.today.month, Date.today.day, 10, 30)
      subject.restart_date = subject.created_at
      subject.end_of_commitment_date = Time.new(Date.today.year + 1, Date.today.month, Date.today.day, 10, 30)
    end

    describe '#commitment_period' do
      it { expect(subject.commitment_period).to match("#{Date.today.year + 1}") }
    end
  end
end
