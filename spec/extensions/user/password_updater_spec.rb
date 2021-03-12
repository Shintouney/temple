require 'rails_helper'

describe User::PasswordUpdater, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:new_password) { 'new_password 12345' }

  it { is_expected.to validate_presence_of(:user) }

  describe "password validations" do
    it { is_expected.to validate_presence_of(:password) }

    it "should validate the password confirmation" do
      subject.password = 'something1234'
      subject.password_confirmation = 'something else'

      expect(subject).not_to be_valid
      expect(subject.errors[:password_confirmation]).not_to be_empty
    end
  end

  it "should update the user password on save" do
    subject.user = user
    subject.password = new_password
    subject.password_confirmation = new_password

    expect(subject.save).to be true

    expect(User.authenticate(user.email, new_password)).to eql(user)
  end

  it "should not update the user password on an unsuccessful save" do
    subject.user = user
    subject.password = new_password
    subject.password_confirmation = "#{new_password}fail"

    expect(subject.save).to be false
    expect(User.authenticate(user.email, new_password)).to be_nil
  end
end
