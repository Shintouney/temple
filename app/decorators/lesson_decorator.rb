class LessonDecorator < ApplicationDecorator
  delegate_all

  include CalendarableDecorator

  # Public: A title describing the record.
  #
  # Returns a String.
  def formatted_title
    formatted_title_with_times(start_at, end_at)
  end

  # Public: Check if a LessonBooking can be created
  # for the Lesson with the given User.
  #
  # user - A User record.
  #
  # Returns a Boolean.
  def bookable_for?(user)
    LessonBooking.new(user: user, lesson: object).bookable?
  end

  # Public: An error text describing the potential validation failures
  # encountered if a LessonBooking would be created for the given User.
  #
  # user - A User record.
  #
  # Returns a String or nil.
  def booking_errors_for(user)
    return nil if (bookable_for?(user) || user.lessons.exists?(object.id))
    error = user_and_lesson_error(user)
    I18n.t(error, scope: 'activerecord.errors.models.lesson_booking') if error
  end

  # Public: Decorates the associated LessonBooking records
  # for this Lesson and order them.
  #
  # Returns a Draper::CollectionDecorator.
  def lesson_bookings
    object.lesson_bookings.order(:created_at).decorate
  end

  # Public: Renders the record as a Hash usable for JSON output.
  #
  # Returns a Hash.
  def to_json
    {
      html_id: h.dom_id(object),
      title: activity,
      formatted_title: formatted_title,
      start: start_at,
      end: end_at,
      className: room_calendar_class_name,
      description: description,
      full_lesson: (available_spots.present? && available_spots > 0 ) || h.current_user.lessons.exists?(object.id) ? false : true,
      full_lesson_title: I18n.t('lessons.decorator.full_lesson_title'),
      full_lesson_texte: I18n.t('lessons.decorator.full_lesson_text'),
      edit_url: h.edit_admin_lesson_path(object),
      show_url: h.lesson_path(object)
    }
  end

  # Public: The number of spots still available for the Lesson.
  #
  # Returns an Integer or nil.
  def available_spots
    return nil unless max_spots
    max_spots - lesson_bookings.size
  end

  # Public: A class name to use when displaying the record in a calendar,
  # to differentiate the room the event is in.
  #
  # Returns a String.
  def room_calendar_class_name
    if !h.current_user || !h.current_user.lessons.exists?(object.id)
      if object.max_spots && object.max_spots <= object.lesson_bookings.count
        "#{super} calendar-full-lesson"
      else
        super
      end
    else
      "#{super} calendar-booked-lesson"
    end
  end

  private

  def user_and_lesson_error(user)
    if false
      'user_has_forbidden_access_to_location'
    elsif !user.card_access_authorized?
      'user_has_forbidden_access'
    elsif !lesson.upcoming?
      'lesson_is_not_upcoming'
    elsif lesson.lesson_bookings.size >= lesson.max_spots
      'max_spots_reached'
    end
  end

  # Private: A text describing the booking status.
  #
  # Returns a String.
  def booking_status
    [lesson_bookings.size, max_spots.presence].compact.join(" / ")
  end
end
