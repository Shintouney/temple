class NotificationSchedules::StartJob < ActiveJob::Base
  queue_as :default

  def perform
    ::NotificationSchedule.all.each do |notification|
      if ::Time.zone.now >= notification.scheduled_at
        ::UserMailer.lesson_booking_confirmation(notification.user_id, notification.lesson_id).deliver_later
        notification.destroy
      end
    end
  end
end
