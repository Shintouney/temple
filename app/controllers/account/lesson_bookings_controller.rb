class Account::LessonBookingsController < ApplicationController
  include AccountController

  before_action :load_lesson
  before_action :build_lesson_booking, only: [:create]
  before_action :load_lesson_booking, only: [:destroy]

  def create
    cancel_other_upcoming_lesson_booking if current_user.has_upcoming_lessons?

    if @lesson_booking.save
      notification = Notification.where(user: @lesson_booking.user)
                                  .where(sourceable_id: @lesson_booking.lesson.id)
                                  .where(sourceable_type: 'Lesson')
      notification.first.destroy if notification.present?
      flash[:notice] = t_action_flash(:notice)

      send_lesson_booking_emails

      render json: { success: true }
    else
      render json: {
        success: false,
        html_content: render_to_string('lessons/show_modal', layout: false)
      }
    end
  end

  def destroy
    @lesson_booking.destroy! if @lesson_booking.present?

    notification_schedule = NotificationSchedule.where(lesson_id: @lesson.id, user_id: current_user.id).first
    notification_schedule.try(:destroy)

    User::SendLessonNotifications.new(@lesson).execute
    flash[:notice] = t_action_flash(:notice)
    render json: { success: true }
  end

  private

  def send_lesson_booking_emails
    Lessons::SendLessonEvent.new(@lesson_booking.user, @lesson_booking.lesson, true).execute if params["send_lesson_event"].present?

    if params["lesson_booking_mail_confirmation"].present?
      NotificationSchedule.create(user: @lesson_booking.user,
                                lesson: @lesson_booking.lesson,
                                scheduled_at: scheduled_calculator)
    end
  end

  def scheduled_calculator
    (Date.today + 2.day) >= Lesson.last.start_at.to_date ? (@lesson_booking.lesson.start_at-12.hours) : (@lesson_booking.lesson.start_at-24.hours)
  end

  def cancel_other_upcoming_lesson_booking
    lesson_booking = current_user.lesson_bookings.includes(:lesson).merge(Lesson.upcoming).references(:lessons).first
    return if lesson_booking.nil?

    notification_schedule = NotificationSchedule.where(lesson_id: lesson_booking.lesson.id, user_id: current_user.id).first
    notification_schedule.try(:destroy)

    lesson = lesson_booking.lesson
    lesson_booking.destroy!

    User::SendLessonNotifications.new(lesson).execute
  end

  def load_lesson
    @lesson = LessonDecorator.decorate(Lesson.find(params[:lesson_id]))
  end

  def load_lesson_booking
    @lesson_booking = @lesson.object.lesson_bookings.find_by(user: current_user)
  end

  def build_lesson_booking
    @lesson_booking = current_user.lesson_bookings.new(lesson: @lesson)
  end
end
