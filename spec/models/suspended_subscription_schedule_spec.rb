require 'rails_helper'

describe SuspendedSubscriptionSchedule do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_presence_of(:scheduled_at) }
  it { is_expected.to validate_presence_of(:subscription_restart_date) }

  describe '#subscription_restart_date_greater_than_scheduled_at' do
    subject { FactoryBot.create(:suspended_subscription_schedule) }

    it "should be valid" do
      subject.subscription_restart_date = Date.today + 5.days
      subject.scheduled_at = Date.today
      
      expect(subject).to be_valid
    end

    it "should not be valid" do
      subject.subscription_restart_date = Date.today
      subject.scheduled_at = Date.today + 5.days

      expect(subject).not_to be_valid
    end
  end
end
