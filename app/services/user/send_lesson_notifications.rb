class User
  class SendLessonNotifications

    attr_reader :lesson

    def initialize(lesson)
      @lesson = lesson
    end

    def execute
      return unless @lesson.max_spots? && @lesson.max_spots > @lesson.lesson_bookings.count

      lesson_notifications = Notification.where(sourceable_type: 'Lesson', sourceable_id: @lesson.id)
      send_notification_mail(lesson_notifications)
    end

    private

    def send_notification_mail(lesson_notifications)
      lesson_notifications.each do |notification|
        UserMailer.send_lesson_notification(notification.sourceable_id, notification.user.id).deliver_later
      end
    end
  end
end
