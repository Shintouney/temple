require 'rails_helper'

describe SubscriptionPlan do
  it_behaves_like "a product model"

  it { is_expected.to have_many(:subscriptions) }

  it { is_expected.to allow_value(nil, 0, 1).for(:commitment_period) }
  it { is_expected.not_to allow_value(-1).for(:commitment_period) }
  it { is_expected.not_to allow_value(2.5).for(:commitment_period) }

  it { is_expected.to allow_value(nil, 0).for(:discount_period) }
  it { is_expected.not_to allow_value(-1).for(:discount_period) }
  it { is_expected.not_to allow_value(2.5).for(:discount_period) }

  it { is_expected.to allow_value(0, 1, 100, nil).for(:position) }

  describe "position validation" do
    subject { FactoryBot.build(:subscription_plan) }

    it "should set the position as first when invalid input is provided" do
      first_subscription_plan = FactoryBot.create(:subscription_plan)

      subject.position = 'abc'

      subject.save!
      subject.reload

      expect(subject.position).to eql(first_subscription_plan.reload.position - 1)
    end
  end

  describe '#require_code?' do
    context "with a code set" do
      before { subject.code = 'ABCD' }

      describe '#require_code?' do
        it { expect(subject.require_code?).to be true }
      end
    end

    context "without a code set" do
      before { subject.code = nil }

      describe '#require_code?' do
        it { expect(subject.require_code?).to be false }
      end
    end
  end

  describe '#expired?' do
    context 'with expire_at in the future' do
      subject { FactoryBot.create(:subscription_plan, expire_at: DateTime.now + 2.days) }

      specify { expect(subject.expired?).to be false }
    end

    context 'with a expire_at in the past' do
      subject { FactoryBot.create(:subscription_plan, expire_at: DateTime.now - 1.month) }

      specify { expect(subject.expired?).to be true }
    end

    context 'with no expire_at' do
      subject { FactoryBot.create(:subscription_plan, expire_at: nil) }

      specify { expect(subject.expired?).to be false }
    end
  end

  describe '#has_subscriptions?' do
    subject { FactoryBot.create(:subscription_plan) }

    context 'with subscriptions' do
      before do
        FactoryBot.create(:subscription, subscription_plan: subject)
      end

      specify { expect(subject.has_subscriptions?).to be true }
    end

    context 'without subscriptions' do
      specify { expect(subject.has_subscriptions?).to be false }
    end
  end

  describe '#has_discount_period?' do
    context "with no discount period" do
      before { subject.discount_period = 0 }

      describe '#has_discount_period?' do
        it { expect(subject.has_discount_period?).to be false }
      end
    end

    context "with a discount period" do
      before { subject.discount_period = 6 }

      describe '#has_discount_period?' do
        it { expect(subject.has_discount_period?).to be true }
      end
    end
  end

  context "with a discount_period" do
    subject { FactoryBot.build(:subscription_plan, discount_period: 6) }

    %i(discounted_price_ati discounted_price_te sponsorship_price_ati sponsorship_price_te).each do |price_attr|
      it { is_expected.to allow_value(nil, 0, 1, 2.5).for(price_attr) }
      it { is_expected.not_to allow_value(-1).for(price_attr) }
    end

    context "with no discounted or sponsorship price set" do
      it "should have an error on discount_period" do
        expect(subject).not_to be_valid
        expect(subject.errors[:discount_period]).not_to be_empty
      end
    end

    context "with a discounted price set" do
      before do
        subject.discounted_price_ati = 400
        subject.discounted_price_te = 380
      end

      specify { expect(subject).to be_valid }

      it "should specify both discounted prices" do
        subject.discounted_price_te = nil

        expect(subject).not_to be_valid
        expect(subject.errors[:discounted_price_te]).not_to be_empty

        subject.discounted_price_ati = nil
        subject.discounted_price_te = 400

        expect(subject).not_to be_valid
        expect(subject.errors[:discounted_price_ati]).not_to be_empty
      end

      it "can not have sponsorship prices" do
        subject.sponsorship_price_te = 200
        subject.sponsorship_price_ati = 220

        expect(subject).not_to be_valid
        expect(subject.errors[:sponsorship_price_ati]).not_to be_empty
        expect(subject.errors[:sponsorship_price_te]).not_to be_empty
      end

      context 'when discounted_price_te equals 0' do
        before { subject.discounted_price_te = 0 }

        context 'when discounted_price_ati is equal to 0' do
          before do
            subject.discounted_price_ati = 0
            subject.save
          end

          it { expect(subject.errors.messages.keys).not_to include(:discounted_price_te) }
        end

        context 'when discounted_price_ati is greater than 0' do
          before do
            subject.discounted_price_ati = 1
            subject.save
          end

          it { expect(subject.errors.messages.keys).to include(:discounted_price_te) }
        end
      end
    end

    context "with a sponsorship price set" do
      before do
        subject.sponsorship_price_ati = 400
        subject.sponsorship_price_te = 380
      end

      specify { expect(subject).to be_valid }

      it "should specify both sponsorship prices" do
        subject.sponsorship_price_te = nil

        expect(subject).not_to be_valid
        expect(subject.errors[:sponsorship_price_te]).not_to be_empty

        subject.sponsorship_price_ati = nil
        subject.sponsorship_price_te = 400

        expect(subject).not_to be_valid
        expect(subject.errors[:sponsorship_price_ati]).not_to be_empty
      end

      context 'when sponsorship_price_te equals 0' do
        before { subject.sponsorship_price_te = 0 }

        context 'when sponsorship_price_ati is equal to 0' do
          before do
            subject.sponsorship_price_ati = 0
            subject.save
          end

          it { expect(subject.errors.messages.keys).not_to include(:sponsorship_price_te) }
        end

        context 'when sponsorship_price_ati is greater than 0' do
          before do
            subject.sponsorship_price_ati = 1
            subject.save
          end

          it { expect(subject.errors.messages.keys).to include(:sponsorship_price_te) }
        end
      end
    end
  end

  context "without a discount_period" do
    FactoryBot.build(:subscription_plan, discount_period: nil)

    it "cannot have a discounted or sponsorship price" do
      %i(discounted_price_ati discounted_price_te sponsorship_price_ati sponsorship_price_te).each do |reduced_price_attr|
        subject.send "#{reduced_price_attr}=", 333

        expect(subject).not_to be_valid
        expect(subject.errors[reduced_price_attr]).not_to be_empty

        subject.send "#{reduced_price_attr}=", nil
      end
    end
  end

  context 'when saving with a nil position' do
    let(:first_subscription) { FactoryBot.build(:subscription_plan, position: nil) }
    let(:new_subscription) { FactoryBot.build(:subscription_plan, position: nil) }

    before do
      first_subscription.save!
      FactoryBot.create(:subscription_plan, position: 1873)
      new_subscription.save!
    end

    specify { expect(first_subscription.position).to eql 1 }
    specify { expect(new_subscription.position).to eql 1874 }
  end

  describe '#destroy' do
    subject { FactoryBot.create(:subscription_plan) }

    context 'with subscriptions' do
      before do
        FactoryBot.create(:subscription, subscription_plan: subject)
      end

      it 'does not destroy the SubscriptionPlan' do
        expect(subject.destroy).to be false

        SubscriptionPlan.exists?(subject.id)
      end
    end

    context 'without subscriptions' do

      it 'destroys the SubscriptionPlan' do
        expect(subject.destroy).to be_truthy

        SubscriptionPlan.exists?(subject.id)
      end
    end
  end
end
