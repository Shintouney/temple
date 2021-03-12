module CalendarableDecorator
  extend ActiveSupport::Concern

  # Public: A description of the LessonTemplate as HTML.
  #
  # Returns a String.
  def description
    [
      h.content_tag(:b, I18n.t('activity_label', scope: 'lessons.decorator')),
      activity,
      h.tag(:br),
      h.content_tag(:b, I18n.t('coach_name_label', scope: 'lessons.decorator')),
      coach_name,
      h.tag(:br),
      h.content_tag(:b, I18n.t('booking_status_label', scope: "#{object.class.model_name.plural}.decorator")),
      booking_status
    ].join
  end

  # Public: A class name to use when displaying the record in a calendar,
  # to differentiate the room the event is in.
  #
  # Returns a String.
  def room_calendar_class_name
    if room.ring?
      'calendar-boxing-ring'
    elsif room.ring_no_opposition?
      'calendar-boxing-ring-no-opposition'
    elsif room.ring_no_opposition_advanced?
      'calendar-boxing-ring-no-opposition_advanced'
    elsif room.ring_feet_and_fist?
      'calendar-boxing-ring-feet-and-fist'
    elsif room.training?
      'calendar-punching-bag'
    else
      'calendar-arsenal'
    end
  end

  private

  def formatted_title_with_times(start_time, end_time)
    [
      activity,
      h.tag(:em, class: 'fa fa-clock-o'),
      I18n.l(start_time, format: '%H:%M'),
      I18n.l(end_time, format: '%H:%M')
    ].join(" - ")
  end
end
