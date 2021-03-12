require 'rails_helper'

describe User::CardUpdater, type: :model do
  let(:user) { FactoryBot.create(:user, card_reference: 'DFE44D34F662D100') }

  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_presence_of(:card_reference) }

  describe "card_reference uniqueness validation" do
    let!(:previous_user) { FactoryBot.create(:user, card_reference: 'DFE44D34F662D101') }

    it "should not accept duplicate card_reference" do
      subject.user = user
      subject.card_reference = previous_user.card_reference

      expect(subject).not_to be_valid
      expect(subject.errors[:base]).not_to be_empty
    end
  end

  describe "card_reference validations" do
    it { is_expected.to allow_value(SecureRandom.hex(8).upcase).for(:card_reference) }
    it { is_expected.not_to allow_value('ABCD').for(:card_reference) }
    it { is_expected.not_to allow_value('123456789 123456').for(:card_reference) }
  end

  it "should update the user card_reference on save" do
    ResamaniaApi::PushUserWorker.should_receive(:perform_async).once.with(user.id)

    new_card_reference = 'DFE44D34F662D103'

    subject.user = user
    subject.card_reference = new_card_reference

    expect(subject.save).to be true

    expect(User.find_by_card_reference(new_card_reference).id).to eql(user.id)
  end

  it "should not update the user card_reference on an unsuccessful save" do
    ResamaniaApi::PushUserWorker.should_not_receive(:perform_async)

    subject.user = user
    subject.card_reference = ''

    expect(subject.save).to be false
  end
end
