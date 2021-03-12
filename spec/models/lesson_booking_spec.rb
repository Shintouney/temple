require 'rails_helper'

describe LessonBooking do
  it { is_expected.to validate_presence_of(:lesson) }
  it { is_expected.to validate_presence_of(:user) }

  it { is_expected.to belong_to(:lesson) }
  it { is_expected.to belong_to(:user) }

  context "available spots validation" do
    let!(:lesson) { FactoryBot.create(:lesson, max_spots: 6) }

    before do
      subject.user = FactoryBot.create(:user)
    end

    context "when there are spots left in the lesson" do
      before do
        5.times { FactoryBot.create(:lesson_booking, lesson: lesson) }
        lesson.reload

        subject.lesson = lesson
      end

      it { is_expected.to be_valid }
    end

    context "when there are no max_spots" do
      before do
        lesson.update_attributes(max_spots: nil)

        subject.lesson = lesson
      end

      it { is_expected.to be_valid }
    end

    context "when no spots are left in the lesson" do
      before do
        6.times { FactoryBot.create(:lesson_booking, lesson: lesson) }
        lesson.reload

        subject.lesson = lesson
      end

      it { is_expected.not_to be_valid }

      it "reports an error on base" do
        subject.valid?

        expect(subject.errors[:base]).not_to be_empty
      end
    end
  end

  context 'user card access validation' do
    let(:user) { FactoryBot.create(:user, card_access: card_access) }
    let(:lesson) { FactoryBot.create(:lesson) }

    before do
      subject.user = user
      subject.lesson = lesson
    end

    context 'when user has card access' do
      let(:card_access) { :authorized }

      it { is_expected.to be_valid }
    end

    context 'when user does not have card access' do
      let(:card_access) { :forbidden }

      it { is_expected.not_to be_valid }

      it 'reports an error on base' do
        subject.valid?

        expect(subject.errors[:base]).not_to be_empty
      end
    end
  end

  context "multiple bookings validation" do
    let!(:upcoming_lesson1) { FactoryBot.create(:lesson, start_at: Time.now + 1.hour, end_at: Time.now + 2.hours) }
    let!(:upcoming_lesson2) { FactoryBot.create(:lesson, start_at: Time.now + 3.hour, end_at: Time.now + 4.hours) }
    let!(:user) { FactoryBot.create(:user) }

    context "when the user has already booked an upcoming lesson" do
      before do
        LessonBooking.create!(user: user, lesson: upcoming_lesson1)

        subject.user = user
        subject.lesson = upcoming_lesson2
      end

      it { is_expected.not_to be_valid }

      it "reports an error on base" do
        subject.valid?

        expect(subject.errors[:base]).not_to be_empty
      end
    end

    context "when the user has already booked a past lesson" do
      before do
        past_lesson = FactoryBot.create(:lesson)
        LessonBooking.create!(user: user, lesson: past_lesson)
        past_lesson.update_attributes!(start_at: Time.now - 1.year, end_at: Time.now - 1.year + 1.day)

        subject.user = user
        subject.lesson = upcoming_lesson2
      end

      it { is_expected.to be_valid }
    end
  end

  context "lesson date validation" do
    let!(:user) { FactoryBot.create(:user) }

    before do
      subject.user = user
      subject.lesson = lesson
    end

    context "when the lesson starts in the future" do
      let!(:lesson) { FactoryBot.create(:lesson) }

      it { is_expected.to be_valid }
    end

    context "when the lesson starts in the past" do
      let!(:lesson) { FactoryBot.create(:lesson) }

      before { lesson.update_attributes!(start_at: (DateTime.yesterday - 14.hours)) }

      it { is_expected.not_to be_valid }

      it "reports an error on base" do
        subject.valid?

        expect(subject.errors[:base]).not_to be_empty
      end
    end
  end
end
