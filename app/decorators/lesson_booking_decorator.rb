class LessonBookingDecorator < ApplicationDecorator
  delegate_all

  delegate :activity, to: :lesson, prefix: true
  decorates_association :user

  # Public: The lesson room name.
  #
  # Returns a String.
  def lesson_room
    lesson.room_text
  end

  # Public: The human-formatted localized lesson start_at Time.
  #
  # Returns a String.
  def lesson_start_at
    I18n.l(lesson.start_at, format: :human)
  end

  # Public: The lesson coach name.
  #
  # Returns a String.
  def lesson_coach
    lesson.coach_name
  end

  def lesson_location
    lesson.location
  end
end
