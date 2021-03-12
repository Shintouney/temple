require 'rails_helper'

describe LessonBookingDecorator do
  subject { LessonBookingDecorator.decorate(FactoryBot.build(:lesson_booking)) }

  describe '#lesson_room' do
    describe '#lesson_room' do
      it { expect(subject.lesson_room).to eql(subject.lesson.room_text) }
    end
  end

  describe '#lesson_start_at' do
    before { subject.lesson.start_at = Time.new(2014, 1, 2, 10, 30) }

    describe '#lesson_start_at' do
      it { expect(subject.lesson_start_at).to match('30') }
    end
  end

  describe '#lesson_activity' do
    describe '#lesson_activity' do
      it { expect(subject.lesson_activity).to eql(subject.lesson.activity) }
    end
  end

  describe '#lesson_coach' do
    describe '#lesson_coach' do
      it { expect(subject.lesson_coach).to eql(subject.lesson.coach_name)}
    end
  end
end
