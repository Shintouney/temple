require 'rails_helper'

describe SubscriptionPlanDecorator do
  subject { SubscriptionPlanDecorator.decorate(FactoryBot.build(:subscription_plan)) }

  describe '#price_ati' do
    before { subject.object.price_ati = 20 }

    describe '#price_ati' do
      it { expect(subject.price_ati).to match('20') }
    end
  end

  %i(discounted_price_ati discounted_price_te sponsorship_price_ati sponsorship_price_te).each do |reduced_price_attr|
    describe "##{reduced_price_attr}" do
      before { subject.object.send "#{reduced_price_attr}=", 20 }

      describe reduced_price_attr do
        it { expect(subject.send(reduced_price_attr)).to match('20') }
      end
    end
  end

  describe '#discount_price_applied?' do
    subject { subscription_plan.decorate }

    context 'with a discount_period and a discounted_price_ati' do
      let(:subscription_plan) { FactoryBot.create(:subscription_plan, :discounted) }

      describe '#discount_price_applied?' do
        it { expect(subject.discount_price_applied?).to be true }
      end
    end

    context 'without a discount_period and a discounted_price_ati' do
      let(:subscription_plan) { FactoryBot.create(:subscription_plan) }

      describe '#discount_price_applied?' do
        it { expect(subject.discount_price_applied?).to be false }
      end
    end
  end

  describe '#displayed_price_ati' do
    context "with no discount period" do
      before { subject.discount_period = 0 }

      describe '#displayed_price_ati' do
        it { expect(subject.displayed_price_ati).to eql subject.price_ati }
      end
    end

    context "with a discount period" do
      subject { subscription_plan.decorate }
      before { subject.discount_period = 6 }

      context 'with a discounted_price_ati' do
        let(:subscription_plan) { FactoryBot.create(:subscription_plan, :discounted, discounted_price_ati: 187.91) }

        describe '#displayed_price_ati' do
          it { expect(subject.displayed_price_ati).to eql "187,91 €" }
        end
      end

      context 'with a sponsorship_price_ati' do
        let(:subscription_plan) { FactoryBot.create(:subscription_plan, :with_sponsorship, sponsorship_price_ati: 2845.13) }

        describe '#displayed_price_ati' do
          it { expect(subject.displayed_price_ati).not_to eql "2 845,13 €" }
        end
      end
    end
  end
end
