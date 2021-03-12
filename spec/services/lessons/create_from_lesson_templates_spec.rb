require 'rails_helper'

describe Lessons::CreateFromLessonTemplates do
  subject { Lessons::CreateFromLessonTemplates.new(date, date_offset) }

  let(:date) { Date.today }
  let(:date_offset) { 2.days }
  let(:other_date) { date + date_offset + 2.days }
  let!(:lesson_templates) do
    [
      FactoryBot.create(:lesson_template, weekday: (date + date_offset).cwday, room: :training),
      FactoryBot.create(:lesson_template, weekday: (date + date_offset).cwday, room: :ring),
      FactoryBot.create(:lesson_template, weekday: (date + date_offset).cwday, room: :arsenal),
      FactoryBot.create(:lesson_template, weekday: (date + date_offset).cwday, room: :ring_no_opposition),
      FactoryBot.create(:lesson_template, weekday: (date + date_offset).cwday, room: :ring_no_opposition_advanced),
      FactoryBot.create(:lesson_template, weekday: (date + date_offset).cwday, room: :ring_feet_and_fist)
    ]
  end
  let!(:other_day_lesson_templates) do
    [
      FactoryBot.create(:lesson_template, weekday: other_date.cwday, room: :training),
      FactoryBot.create(:lesson_template, weekday: other_date.cwday, room: :ring),
      FactoryBot.create(:lesson_template, weekday: other_date.cwday, room: :arsenal),
      FactoryBot.create(:lesson_template, weekday: other_date.cwday, room: :ring_no_opposition),
      FactoryBot.create(:lesson_template, weekday: other_date.cwday, room: :ring_no_opposition_advanced),
      FactoryBot.create(:lesson_template, weekday: other_date.cwday, room: :ring_feet_and_fist)
    ]
  end

  describe '#date' do
    it { expect(subject.date).to eql(date + date_offset) }
  end
  specify { expect(subject.lesson_templates.to_a).to eql(lesson_templates) }

  describe '#execute' do
    it 'creates lessons for given day' do
      expect{ subject.execute }.to change{ Lesson.within_period((date + date_offset).to_s,
                                                                (date + date_offset + 1.day).to_s).count }.by(Lesson.room.values.size)
    end

    context 'with existing lessons' do
      let!(:lesson) { FactoryBot.create(:lesson, start_at: date + date_offset, end_at: other_date) }

      it 'does not create overlapping lessons' do
        expect{ subject.execute }.to change{ Lesson.within_period((date + date_offset).to_s,
                                                                 (date + date_offset + 1.day).to_s).count }.by(Lesson.room.values.size - 1)
      end
    end
  end
end
