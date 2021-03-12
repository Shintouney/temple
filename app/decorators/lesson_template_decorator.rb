class LessonTemplateDecorator < ApplicationDecorator
  delegate_all

  include CalendarableDecorator

  # Public: A start date formed by the weekday and start_at_hour of the record,
  # with the current week as the origin.
  # This is used for rendering the record as an event on a calendar.
  #
  # Returns a Time.
  def start_at_as_current_week_date
    Time.now.beginning_of_week + ((weekday - 1).days) + start_at_hour.to_i
  end

  # Public: An end date formed by the weekday and end_at_hour of the record,
  # with the current week as the origin.
  # This is used for rendering the record as an event on a calendar.
  #
  # Returns a Time.
  def end_at_as_current_week_date
    Time.now.beginning_of_week + ((weekday - 1).days) + end_at_hour.to_i
  end

  # Public: A title describing the record.
  #
  # Returns a String.
  def formatted_title
    formatted_title_with_times(start_at_as_current_week_date, end_at_as_current_week_date)
  end

  # Public: Renders the record as a Hash usable for JSON output.
  #
  # Returns a Hash.
  def to_json
    {
      html_id: h.dom_id(object),
      title: activity,
      formatted_title: formatted_title,
      start: start_at_as_current_week_date,
      end: end_at_as_current_week_date,
      className: room_calendar_class_name,
      description: description,
      edit_url: h.edit_admin_lesson_template_path(object)
    }
  end

  private

  # Private: A text describing the booking status.
  #
  # Returns a String.
  def booking_status
    max_spots || '-'
  end
end
