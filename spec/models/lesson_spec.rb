require 'rails_helper'

describe Lesson do
  it_behaves_like "a model with lessons attributes"

  it { is_expected.to validate_presence_of(:start_at) }
  it { is_expected.to validate_presence_of(:end_at) }

  it { is_expected.to belong_to(:lesson_template) }
  it { is_expected.to have_many(:lesson_bookings) }
  it { is_expected.to have_many(:notifications) }

  describe "end_at validation" do
    subject { FactoryBot.build(:lesson) }

    it "does not accept an end_at before the start_at" do
      subject.start_at = Time.now + 14.hours
      subject.end_at = Time.now + 8.hours
      expect(subject).not_to be_valid
      expect(subject.errors[:end_at]).not_to be_empty
    end

    it "does not accept an end_at equal to the start_at" do
      subject.start_at = Time.now + 14.hours
      subject.end_at = subject.start_at
      expect(subject).not_to be_valid
      expect(subject.errors[:end_at]).not_to be_empty
    end

    it "does not accept an end_at 29 minutes after the start_at" do
      subject.start_at = Time.now + 14.hours
      subject.end_at = Time.now + 14.hours + 29.minutes
      expect(subject).not_to be_valid
      expect(subject.errors[:end_at]).not_to be_empty
    end

    it "accepts an end_at 30 minutes after the start_at" do
      subject.start_at = Time.now + 14.hours
      subject.end_at = Time.now + 14.hours + 30.minutes
      expect(subject).to be_valid
    end
  end

  describe "start_at validation" do
    subject { FactoryBot.build(:lesson) }

    it "does not accept a start_at in the past" do
      subject.start_at = Time.now - 14.hours
      subject.end_at = Time.now + 8.hours
      expect(subject).not_to be_valid
      expect(subject.errors[:start_at]).not_to be_empty
    end

    it "accepts a start_at in the future" do
      subject.start_at = Time.now + 14.hours
      subject.end_at = Time.now + 20.hours
      expect(subject).to be_valid
    end

    it "can have a start_at in the past on edition" do
      subject.save!

      subject.start_at = Time.now - 3.hours
      subject.end_at = Time.now - 2.hours
      expect(subject).to be_valid
    end
  end

  describe 'overlap validation' do
    subject { FactoryBot.build(:lesson, room: :training) }

    context 'with no overlapping lessons' do
      describe '#valid?' do
        it { expect(subject.valid?).to be true }
      end
    end

    context 'with overlapping lessons in a different room' do
      let!(:lesson) { FactoryBot.create(:lesson, room: :ring, start_at: subject.start_at - 3.hours, end_at: subject.end_at + 1.minute) }

      describe '#valid?' do
        it { expect(subject.valid?).to be true }
      end
    end

    context 'with overlapping lessons in the same room' do
      let!(:lesson) { FactoryBot.create(:lesson, room: :training, start_at: subject.start_at - 3.hours, end_at: subject.end_at + 1.minute) }

      describe '#valid?' do
        it { expect(subject.valid?).to be false }
      end
    end

    context 'with successive lessons in the same room' do
      let!(:lesson) { FactoryBot.create(:lesson, room: :training, start_at: subject.end_at, end_at: subject.end_at + 2.hours) }

      describe '#valid?' do
        it { expect(subject.valid?).to be true }
      end
    end
  end

  describe 'max_spots_greater_or_equal_than_bookings validation' do
    subject { FactoryBot.build(:lesson, room: :training, max_spots: nil) }

    before do
      allow(subject.lesson_bookings).to receive(:any?) { true }
      allow(subject.lesson_bookings).to receive(:size) { 2 }
    end

    context 'no max_spots' do
      it 'does not raise errors' do
        expect(subject).to be_valid
      end
    end

    context 'max spots higher than booked lessons' do
      before do
        subject.max_spots = 3
      end
      it 'does not raise errors' do
        expect(subject).to be_valid
      end
    end

    context 'max_spots lower than booked lessons' do
      before do
        subject.max_spots = 1
      end
      it 'raise an error' do
        expect(subject).not_to be_valid
      end
    end
  end

  describe '#upcoming?' do
    context "when start_at is in the future" do
      before { subject.start_at = (Time.now + 14.hours) }

      describe '#upcoming?' do
        it { expect(subject.upcoming?).to be true }
      end
    end

    context "when start_at is in the past" do
      before { subject.start_at = (Time.now - 14.hours) }

      describe '#upcoming?' do
        it { expect(subject.upcoming?).to be false }
      end
    end

    context "when start_at is nil" do
      before { subject.start_at = nil }

      describe '#upcoming?' do
        it { expect(subject.upcoming?).to be false }
      end
    end
  end

  describe '#duration' do
    before do
      subject.start_at = Time.now
      subject.end_at = subject.start_at + 6.minutes
    end

    describe '#duration' do
      it { expect(subject.duration).to eq(6 * 60) }
    end
  end

  describe '#overlaps?' do
    subject { FactoryBot.build(:lesson, room: :training) }

    context 'with no overlapping lessons' do
      describe '#overlaps?' do
        it { expect(subject.overlaps?).to be false }
      end
    end

    context 'with overlapping lessons in a different room' do
      let!(:lesson) { FactoryBot.create(:lesson, room: :ring, start_at: subject.start_at - 3.hours, end_at: subject.end_at + 1.minute) }

      describe '#overlaps?' do
        it { expect(subject.overlaps?).to be false }
      end
    end

    context 'with overlapping lessons in the same room' do
      let!(:lesson) { FactoryBot.create(:lesson, room: :training, start_at: subject.start_at - 3.hours, end_at: subject.end_at + 1.minute) }

      describe '#overlaps?' do
        it { expect(subject.overlaps?).to be true }
      end
    end

    context 'with an empty room' do
      subject { FactoryBot.build(:lesson, room: nil) }

      describe '#overlaps?' do
        it { expect(subject.overlaps?).to be false }
      end
    end

    context 'ignores self' do
      subject { FactoryBot.create(:lesson) }

      describe '#overlaps?' do
        it { expect(subject.overlaps?).to be false }
      end
    end
  end

  describe '.within_period' do
    let(:older_lesson) { FactoryBot.create(:lesson, start_at: Time.local(2014, 1, 15, 16, 30), end_at: Time.local(2014, 1, 15, 17, 30)) }
    let(:current_week_lesson) { FactoryBot.create(:lesson, start_at: Time.local(2014, 1, 21, 16, 30), end_at: Time.local(2014, 1, 21, 17, 30)) }
    let(:newer_lesson) { FactoryBot.create(:lesson, start_at: Time.local(2014, 1, 28, 16, 30), end_at: Time.local(2014, 1, 28, 17, 30)) }

    before do
      Timecop.travel(2014, 1, 1)
      older_lesson
      current_week_lesson
      newer_lesson
      Timecop.return
    end

    it "only returns records within the given period" do
      expect(Lesson.within_period("2014-01-20", "2014-01-26").map(&:id)).to eql([current_week_lesson.id])
    end
  end

  describe '#located' do
    context "Lesson are located in moliere" do
      before { FactoryBot.create(:lesson) }

      it "Must find the lesson" do
        expect(Lesson.located('moliere').count).to eql 1
      end

      it "Must not find the lesson" do
        expect(Lesson.located('maillot').count).to eql 0
      end

      it "Must not find the lesson" do
        expect(Lesson.located('amelot').count).to eql 0
      end
    end
  end
end
