require 'rails_helper'

describe SubscriptionPlanSelectionValidator, type: :model do
  let(:sponsor) { FactoryBot.create(:user) }

  it { is_expected.to validate_presence_of(:subscription_plan) }

  describe "code validations" do
    subject { SubscriptionPlanSelectionValidator.new(subscription_plan: subscription_plan) }

    context "when no code is required" do
      let(:subscription_plan) { FactoryBot.create(:subscription_plan, code: nil) }

      it "accepts a blank code" do
        expect(subject).to be_valid
      end
    end

    context "when a code is required" do
      let(:code) { "ABCDE" }
      let(:subscription_plan) { FactoryBot.create(:subscription_plan, code: code) }

      it "does not accept a blank code" do
        expect(subject).not_to be_valid
        expect(subject.errors[:code]).not_to be_empty
      end

      it "accepts a correct code" do
        subject.code = code

        expect(subject).to be_valid
      end

      it "does not accept an invalid code" do
        subject.code = "invalid"

        expect(subject).not_to be_valid
        expect(subject.errors[:code]).not_to be_empty
      end
    end
  end
end
