require 'rails_helper'

describe ResetPasswordRequest, type: :model do
  let(:user) { FactoryBot.create(:user) }

  it { is_expected.not_to be_valid }

  it "should set its user from its email" do
    subject.email = user.email
    expect(subject.user).to eql(user)
  end

  it "should validate presence of user" do
    subject.email = 'foo@example.com'

    expect(subject).not_to be_valid
    expect(subject.errors[:user]).not_to be_empty
  end

  it "should accept existing users" do
    subject.email = user.email

    expect(subject).to be_valid
  end
end
