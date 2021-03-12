require 'rails_helper'

describe Subscription do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:user) }

  it { is_expected.to belong_to(:subscription_plan) }
  it { is_expected.to validate_presence_of(:subscription_plan) }

  it { is_expected.to validate_presence_of(:start_at) }

  it { is_expected.to allow_value(nil, 0, 1).for(:discount_period) }
  it { is_expected.not_to allow_value(-1).for(:discount_period) }
  it { is_expected.not_to allow_value(2.5).for(:discount_period) }

  describe '#state' do
    it "should be pending on initial state" do
      expect(subject.state).to eql('pending')
    end
  end

  describe '#start' do
    subject { FactoryBot.create(:subscription) }

    # it "requires a start_at date not in the future" do
    #   subject.update_attributes(start_at: Date.tomorrow)

    #   expect(subject.start).to be false
    # end

    it "authorizes the user's card access" do
      subject.start_at = Date.today
      expect(subject.user).to receive(:authorize_card_access)
      subject.start!
    end

    context "with a subscription_plan" do
      let(:subscription_plan) { FactoryBot.create(:subscription_plan) }
      before do
        subject.update_attributes!(subscription_plan: subscription_plan,
                                  start_at: Date.yesterday)
      end
    end
  end

  describe '#temporarily_suspend' do
    subject { FactoryBot.create(:subscription) }

    it "should failed if state is not running" do
      subject.update_attributes(restart_date: nil)

      expect(subject).to_not allow_transition_to(:temporarily_suspend)
    end

    it "should failed without restart_date" do
      subject.update_attributes(restart_date: nil)
      subject.start!

      expect(subject.temporarily_suspend!).to be false
    end

    it "should temporarily suspend subscription" do
      subject.update_attributes(restart_date: subject.next_payment_at.to_date + 1.day)
      subject.start!

      expect(subject.temporarily_suspend!).to be true
    end
  end

  describe 'transition from temporarily_suspend to running' do
    subject { FactoryBot.create(:subscription) }

    it "should failed if state is not running" do
      FactoryBot.create(:invoice, user: subject.user, state: :open)

      subject.update_attributes(restart_date: subject.next_payment_at.to_date + 1.day)

      subject.start!
      expect(subject.temporarily_suspend!).to be true
      expect(subject.user.card_access).to eq("forbidden")
      expect(subject.restart!).to be true
      expect(subject.start_at).to eq(Date.today)
      expect(subject.user.card_access).to eq("authorized")
    end
  end

  describe '#cancel' do
    subject { FactoryBot.create(:subscription, state: :running) }
    before do
      FactoryBot.create(:invoice, user: subject.user)
    end
    it "full fill end_at suspension date" do
      subject.should_receive(:update_attribute)
      subject.cancel!
    end
  end

  describe '#commitment_running?' do
    subject { FactoryBot.create(:subscription) }

    context "when the commitment_period is positive" do
      before { subject.update_attribute :commitment_period, 6 }

      describe '#commitment_running?' do
        it { expect(subject.commitment_running?).to be true }
      end
    end

    context "when the commitment_period is over" do
      before { subject.update_attribute :commitment_period, 0 }

      describe '#commitment_running?' do
        it { expect(subject.commitment_running?).to be false }
      end
    end
  end

  describe '#discount_running?' do
    subject { FactoryBot.create(:subscription) }

    context "when the discount_period is positive" do
      before { subject.update_attribute :discount_period, 6 }

      describe '#discount_running?' do
        it { expect(subject.discount_running?).to be true }
      end
    end

    context "when the discount_period is over" do
      before { subject.update_attribute :discount_period, 0 }

      describe '#discount_running?' do
        it { expect(subject.discount_running?).to be false }
      end
    end
  end

  describe '#current_period_start_date' do
    subject { FactoryBot.create(:subscription, start_at: Date.new(2010, 2, 15)) }

    after { Timecop.return }

    context 'the first month' do
      before { Timecop.travel(2010, 2, 15, 14, 00, 00) }

      describe '#current_period_start_date' do
        it { expect(subject.current_period_start_date).to eql Date.new(2010, 2, 15) }
      end
    end

    context 'the next month' do
      before { Timecop.travel(2010, 3, 15, 14, 00, 00) }

      describe '#current_period_start_date' do
        it { expect(subject.current_period_start_date).to eql Date.new(2010, 3, 15) }
      end
    end

    context 'a year later' do
      before { Timecop.travel(2011, 3, 5, 14, 00, 00) }

      describe '#current_period_start_date' do
        it { expect(subject.current_period_start_date).to eql Date.new(2011, 3, 15) }
      end
    end

    context "when the day of subscription is 31" do
      before { Timecop.travel(2010, 8, 31, 14, 00, 00) }
      subject { FactoryBot.create(:subscription, start_at: Date.new(2010, 8, 31), next_payment_at: (Date.new(2010, 8, 31) + 1.month)) }

      before do
        subject.start!
      end

      describe '#start_at' do
        it { expect(subject.start_at).to eql Date.new(2010, 8, 31) }
      end

      describe '#next_payment_at' do
        it { expect(subject.next_payment_at).to eql Date.new(2010, 9, 30) }
      end

      context "the next month (m+1) which do NOT have a day 31" do
        before { Timecop.travel(2010, 9, 30, 14, 00, 00) }

        describe '#current_period_start_date' do
          it { expect(subject.current_period_start_date).to eql Date.new(2010, 9, 30) }
        end
      end
      context "the month after that (m+2) which DO have a day 31" do
        before { Timecop.travel(2010, 10, 31, 14, 00, 00) }

        describe '#current_period_start_date' do
          it { expect(subject.current_period_start_date).to eql Date.new(2010, 10, 31) }
        end
      end
    end
    context "when the day of subscription is 31 and the month borders February special case" do
      before { Timecop.travel(2010, 1, 31, 14, 00, 00) }
      subject { FactoryBot.create(:subscription, start_at: Date.new(2010, 1, 31), next_payment_at: (Date.new(2010, 1, 31) + 1.month)) }

      before do
        subject.start!
      end

      describe '#start_at' do
        it { expect(subject.start_at).to eql Date.new(2010, 1, 31) }
      end

      describe '#next_payment_at' do
        it { expect(subject.next_payment_at).to eql Date.new(2010, 2, 28) }
      end

      context "the next month (m+1) has only 28 days" do
        before { Timecop.travel(2010, 2, 28, 14, 00, 00) }

        describe '#current_period_start_date' do
          it { expect(subject.current_period_start_date).to eql Date.new(2010, 2, 28) }
        end

        describe '#current_period_end_date' do
          it { expect(subject.current_period_end_date).to eql Date.new(2010, 3, 30)}
        end
      end
      context "the month after that (m+2) which DO have a day 31 on 27th" do
        before { Timecop.travel(2010, 3, 27, 14, 00, 00) }

        describe '#current_period_start_date' do
          it { expect(subject.current_period_start_date).to eql Date.new(2010, 3, 27) }
        end

        describe '#current_period_end_date' do
          it { expect(subject.current_period_end_date).to eql Date.new(2010, 4, 29)}
        end
      end
      context "the month after that (m+2) which DO have a day 31 on 28th" do
        before { Timecop.travel(2010, 3, 28, 14, 00, 00) }

        describe '#current_period_start_date' do
          it { expect(subject.current_period_start_date).to eql Date.new(2010, 3, 28) }
        end

        describe '#current_period_end_date' do
          it { expect(subject.current_period_end_date).to eql Date.new(2010, 4, 29)}
        end
      end
      context "the month after that (m+2) which DO have a day 31 on 30" do
        before { Timecop.travel(2010, 3, 30, 14, 00, 00) }

        describe '#current_period_start_date' do
          it { expect(subject.current_period_start_date).to eql Date.new(2010, 3, 30) }
        end

        describe '#current_period_end_date' do
          it { expect(subject.current_period_end_date).to eql Date.new(2010, 4, 29)}
        end
      end
    end
  end

  describe '#current_period_end_date' do
    subject { FactoryBot.create(:subscription, start_at: Date.new(2010, 2, 15)) }

    after { Timecop.return }

    context 'the first month' do
      before { Timecop.travel(2010, 3, 14, 14, 00, 00) }

      describe '#current_period_end_date' do
        it { expect(subject.current_period_start_date).to eql Date.new(2010, 3, 15) }
        it { expect(subject.current_period_end_date).to eql Date.new(2010, 4, 14) }
      end
    end

    context 'the next month' do
      before { Timecop.travel(2010, 3, 15, 14, 00, 00) }

      describe '#current_period_end_date' do
        it { expect(subject.current_period_end_date).to eql Date.new(2010, 4, 14) }
      end
    end

    context 'a year later' do
      before { Timecop.travel(2011, 3, 5, 14, 00, 00) }

      describe '#current_period_end_date' do
        it { expect(subject.current_period_start_date).to eql Date.new(2011, 3, 15) }
        it { expect(subject.current_period_end_date).to eql Date.new(2011, 4, 14) }
      end
    end
  end
end
