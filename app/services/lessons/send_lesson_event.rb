require 'icalendar/tzinfo'

module Lessons
  class SendLessonEvent
    attr_reader :user, :calendar, :lesson

    def initialize(user, lesson, require_ics)
      @user = user
      @require_ics = require_ics
      @ics_path = Settings.mailer.ics_path + "42#{@user.id}875843.ics"
      @lesson = lesson
      @timezone_id = 'Europe/Paris'
      @event_start = lesson.start_at
    end

    def execute
      if @require_ics
        @calendar = Icalendar::Calendar.new

        create_timezone
        create_calendar_event
        @calendar.append_custom_property 'METHOD', 'REQUEST'
        @calendar.ip_method = 'REQUEST'
        create_ics_file
      end
      UserMailer.send_ical_invite(user.id, lesson.id, @ics_path, @require_ics).deliver_later
    end

    private
    def create_calendar_event
      event = Icalendar::Event.new
      event = setup_calendar_event(event)
      event = setup_calendar_event_alarm(event)

      @calendar.add_event(event)
    end

    def setup_calendar_event(event)
      event.organizer   = Icalendar::Values::CalAddress.new("contact@temple-nobleart.fr", cn: 'Le Temple - Noble art')
      event.dtstart     = Icalendar::Values::DateTime.new(@event_start, tzid: @timezone_id)
      event.dtend       = Icalendar::Values::DateTime.new(lesson.end_at, tzid: @timezone_id)
      event.summary     = I18n.t('lessons.send_lesson_event.lesson_temple', location: I18n.t("location.#{@lesson.location}"))
      event.description = I18n.t('lessons.send_lesson_event.lesson_description',
                                 coach_name: lesson.coach_name,
                                 activity: lesson.activity,
                                 start_time: I18n.l(@event_start, format: "%H:%M"),
                                 start_date: I18n.l(@event_start, format: "%A %e %B")
                                )
      event.ip_class    = "PUBLIC"
      event.location    = @lesson.location == "moliere" ? "11 rue Molière 75001 Paris" : @lesson.location == "maillot" ? "66 boulevard Gouvion Saint-Cyr 75017 Paris" : "138 rue Amelot 75011 Paris"
      event.geo = [Icalendar::Values::Float.new(48.8651978), Icalendar::Values::Float.new(2.3356653)]
      event
    end

    def setup_calendar_event_alarm(event)
      event.alarm do |a|
        a.action          = "EMAIL"
        a.description     = I18n.t('lessons.send_lesson_event.lesson_description',
                                   coach_name: lesson.coach_name,
                                   activity: lesson.activity,
                                   start_time: I18n.l(@event_start, format: "%H:%M"),
                                   start_date: I18n.l(@event_start, format: "%A %e %B")
                                  )
        a.summary         = I18n.t('lessons.send_lesson_event.lesson_temple_alarm')        # email subject (required)
        a.attendee        = "mailto:#{user.email}" # one or more email recipients (required)
        a.trigger         = "-PT60M" # 60 minutes before
      end
      event
    end

    def create_timezone
      tz_info = TZInfo::Timezone.get(@timezone_id)
      timezone = tz_info.ical_timezone(@event_start)
      @calendar.add_timezone timezone
    end

    def create_ics_file
      if File.exist?(@ics_path)
        File.delete(@ics_path)
      end

      f = File.open(@ics_path, "w+")
      f.write(@calendar.to_ical)
      f.close
    end
  end
end
