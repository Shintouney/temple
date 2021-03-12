require 'rails_helper'

describe LessonDraft do
  it_behaves_like "a model with lessons attributes"

  it { is_expected.to validate_presence_of(:weekday) }
  it { is_expected.to validate_presence_of(:start_at_hour) }
  it { is_expected.to validate_presence_of(:end_at_hour) }

  it { is_expected.to validate_numericality_of(:max_spots) }

  it { is_expected.to have_many(:lessons) }

  describe "end_at_hour validation" do
    subject { FactoryBot.build(:lesson_draft) }

    it "does not accept an end_at_hour before the start_at_hour" do
      subject.start_at_hour = Tod::TimeOfDay.new(16)
      subject.end_at_hour = Tod::TimeOfDay.new(15)

      expect(subject).not_to be_valid
      expect(subject.errors[:end_at_hour]).not_to be_empty
    end

    it "does not accept an end_at_hour equal to the start_at_hour" do
      subject.start_at_hour = Tod::TimeOfDay.new(16)
      subject.end_at_hour = subject.start_at_hour

      expect(subject).not_to be_valid
      expect(subject.errors[:end_at_hour]).not_to be_empty
    end

    it "does not accept an end_at 29 minutes after the start_at" do
      subject.start_at_hour = Tod::TimeOfDay.new(16)
      subject.end_at_hour = Tod::TimeOfDay.new(16, 29)

      expect(subject).not_to be_valid
      expect(subject.errors[:end_at_hour]).not_to be_empty
    end

    it "accepts an end_at_hour 30 minutes after the start_at_hour" do
      subject.start_at_hour = Tod::TimeOfDay.new(16)
      subject.end_at_hour = Tod::TimeOfDay.new(16, 30)
      expect(subject).to be_valid
    end
  end

  describe '#duration' do
    before do
      subject.start_at_hour = Tod::TimeOfDay.new(16)
      subject.end_at_hour = subject.start_at_hour + 6.minutes
    end

    describe '#duration' do
      it { expect(subject.duration).to eq(6 * 60) }
    end
  end

  describe '#located' do
    context "Lesson are located in moliere" do
      before { FactoryBot.create(:lesson_draft) }

      it "Must find the lesson" do
        expect(LessonDraft.located('moliere').count).to eql 1
      end

      it "Must not find the lesson" do
        expect(LessonDraft.located('maillot').count).to eql 0
      end

      it "Must not find the lesson" do
        expect(LessonDraft.located('amelot').count).to eql 0
      end
    end
  end
end
