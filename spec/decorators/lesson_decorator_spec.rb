require 'rails_helper'

describe LessonDecorator do
  let!(:lesson) { FactoryBot.create(:lesson) }
  let!(:user) { FactoryBot.create(:user, :with_running_subscription) }

  subject { LessonDecorator.decorate(lesson) }

  it_behaves_like "a calendarable decorator"

  describe '#bookable_for?' do
    context "with a bookable lesson" do
      it "should return true" do
        expect(subject.bookable_for?(user)).to be true
      end
    end

    context "with another lesson already booked" do
      before do
        LessonBooking.create(user: user, lesson: FactoryBot.create(:lesson))
      end

      it "should return false" do
        expect(subject.bookable_for?(user)).to be true
      end
    end

    context "with a full lesson" do
      before do
        lesson.update_attributes max_spots: 1
        LessonBooking.create(user: user, lesson: lesson)
        subject.reload
      end

      it "should return false" do
        expect(subject.bookable_for?(user)).to be false
      end
    end
  end

  describe '#booking_errors_for' do
    before do
      lesson.max_spots = 1
      lesson.save!
    end

    context "with a bookable lesson" do
      it "should return nil" do
        expect(subject.booking_errors_for(user)).to be_nil
      end
    end

    context "with the lesson already booked for the user" do
      before { LessonBooking.create!(lesson: lesson, user: user) }

      it "should return nil" do
        expect(subject.booking_errors_for(user)).to be_nil
      end
    end

    context "with a non-bookable lesson" do
      context 'when no spots are available for the lesson' do
        before { lesson.update_attribute(:max_spots, 0) }

        it "should return an error text" do
          expect(subject.booking_errors_for(user)).to eq(I18n.t('max_spots_reached', scope: 'activerecord.errors.models.lesson_booking'))
        end
      end

      context 'when user card access is forbidden' do
        before { user.update_attributes!(card_access: :forbidden) }

        it "should return an error text" do
          expect(subject.booking_errors_for(user)).to eq(I18n.t('user_has_forbidden_access', scope: 'activerecord.errors.models.lesson_booking'))
        end
      end

      context 'lesson is in the past' do
        before do
          lesson.start_at = Date.today - 1.day
        end
        it 'returns a not upcoming lesson error message' do
          expect(subject.booking_errors_for(user)).to eq(I18n.t('lesson_is_not_upcoming', scope: 'activerecord.errors.models.lesson_booking'))
        end
      end
    end
  end

  describe '#lesson_bookings' do
    let!(:lesson_bookings) { FactoryBot.create_list(:lesson_booking, 2, lesson: lesson) }

    it "should return the lesson_bookings for the lesson" do
      expect(subject.lesson_bookings.size).to eql(2)
    end
  end

  describe '#room_calendar_class_name' do
    before do
      lesson.update_attributes room: :ring
    end

    context "with a current_user set" do
      before do
        allow(subject.helpers).to receive(:current_user).and_return(user)
      end

      context "with bookings for the user" do
        before do
          FactoryBot.create(:lesson_booking, lesson: lesson, user: user)
          lesson.reload
        end

        it "should return a class name identifying that the lesson is booked for the user" do
          expect(subject.room_calendar_class_name).to eql('calendar-boxing-ring calendar-booked-lesson')
        end
      end

      context "with no bookings for the lesson" do
        it "should return a class name identifying the room" do
          expect(subject.room_calendar_class_name).to match('boxing-ring')
        end
      end
    end

    context "with no current_user set" do
      it "should return a class name identifying the room" do
        expect(subject.room_calendar_class_name).to match('boxing-ring')
      end
    end
  end

  describe '#available_spots' do
    context "with max_spots and bookings for the lesson" do
      before do
        lesson.update_attributes! max_spots: 4
        FactoryBot.create(:lesson_booking, lesson: lesson)
        lesson.reload
      end

      it "should return the number of available lesson bookings" do
        expect(subject.available_spots).to eql(3)
      end
    end

    context "with no max spots for the lesson" do
      it "should return nil" do
        expect(subject.available_spots).to eql(4)
      end
    end
  end
end
