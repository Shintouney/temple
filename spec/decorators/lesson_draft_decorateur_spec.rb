require 'rails_helper'

describe LessonDraftDecorator do
  subject { LessonDraftDecorator.decorate(FactoryBot.build(:lesson_draft)) }

  it_behaves_like "a calendarable decorator"

  describe '#start_at_as_current_week_date' do
    before do
      subject.start_at_hour = Tod::TimeOfDay.new(14, 45)
      subject.weekday = 6
    end

    it 'should return a Time' do
      expect(subject.start_at_as_current_week_date).to be_a(Time)
      expect(subject.start_at_as_current_week_date.wday).to eql(subject.weekday)
      expect(subject.start_at_as_current_week_date.hour).to eql(14)
      expect(subject.start_at_as_current_week_date.min).to eql(45)
    end
  end

  describe '#end_at_as_current_week_date' do
    before do
      subject.end_at_hour = Tod::TimeOfDay.new(18, 15)
    end

    it 'should return a Time' do
      expect(subject.end_at_as_current_week_date).to be_a(Time)
      expect(subject.end_at_as_current_week_date.hour).to eql(18)
      expect(subject.end_at_as_current_week_date.min).to eql(15)
    end
  end

  describe '#to_json' do
    before { subject.save! }

    describe '#to_json' do
      it { expect(subject.to_json).to be_a(Hash) }
    end
  end
end
