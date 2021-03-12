module Lessons
  class CreateFromLessonTemplates
    attr_reader :date, :lesson_templates

    def initialize(target_date = Date.today, date_offset = 6.week)
      @date = target_date + date_offset
      @lesson_templates = LessonTemplate.where(weekday: date.cwday)
    end

    def execute
      lesson_templates.each do |lesson_template|
        create_lesson_from_lesson_template(lesson_template)
      end
    end

    private

    def create_lesson_from_lesson_template(lesson_template)
      lesson = lesson_template.lessons.build(room: lesson_template.room,
                                             coach_name: lesson_template.coach_name,
                                             activity: lesson_template.activity,
                                             max_spots: lesson_template.max_spots,
                                             start_at: lesson_template.start_at_hour.on(date),
                                             end_at: lesson_template.end_at_hour.on(date),
                                             location: lesson_template.location)

      lesson.save
    end
  end
end
