# encoding: UTF-8
include ActionView::Helpers::NumberHelper
require 'fileutils'

module CSVExporter
  class LessonBookings < Base
    COLUMNS = {
      lesson_location: Lesson.human_attribute_name(:location),
      lesson_start_at: Lesson.human_attribute_name(:start_at),
      lesson_room: Lesson.human_attribute_name(:room),
      lesson_activity: Lesson.human_attribute_name(:activity),
      lesson_coach_name: Lesson.human_attribute_name(:coach_name),
      lesson_max_spots: Lesson.human_attribute_name(:max_spots),
      lesson_number_of_member: I18n.t('admin.exports.lesson_booking.lesson_number_of_member'),
      lastname: User.human_attribute_name(:lastname),
      firstname: User.human_attribute_name(:firstname),
      id: User.human_attribute_name(:id),
      email: User.human_attribute_name(:email),
      user_state: I18n.t('admin.exports.lesson_booking.user_state'),
      subscription_start_at: I18n.t('admin.exports.lesson_booking.subscription_start_at'),
      subscription_end_at: I18n.t('admin.exports.lesson_booking.subscription_end_at'),
      created_at: I18n.t('admin.exports.lesson_booking.created_at')
    }

    def initialize(export)
      @export = export
    end

    def execute
      csv_string = ""
      FileUtils.mkdir_p 'tmp/exports'
      begin
        @elements_to_csv = load_sorted_elements(@export.lesson_bookings)

        csv_string = CsvShaper::Shaper.encode do |csv_content|
                      headers(csv_content)
                      rows(csv_content)
                     end

        File.open(@export.path, 'w') { |file| file.write("\xEF\xBB\xBF" + csv_string) }
        @export.complete!
      rescue StandardError => e
        @export.destroy
        Raven.capture_exception(e)
      ensure
        @export.progress_tracker.delete
      end
      csv_string
    end

    private
    def load_sorted_elements(lesson_bookings)
      lesson_bookings.sort do |a, b|
        (a.lesson.present? && b.lesson.present?) ? a.lesson.start_at <=> b.lesson.start_at : a.created_at <=> b.created_at
      end if lesson_bookings.present?
    end

    def headers(csv)
      csv.headers do |csv_header|
        csv_header.columns(*COLUMNS.keys)
        csv_header.mappings COLUMNS
      end
    end

    def rows(csv)
      csv.rows @elements_to_csv do |csv_row, lesson_booking|
        lesson = lesson_booking.lesson
        user = lesson_booking.user
        subscription = user.subscriptions.last if user.present?

        csv_row.cell :created_at, I18n.l(lesson_booking.created_at)
        map_user_row(csv_row, user)
        map_lesson_row(csv_row, lesson) if lesson.present?
        map_subscription_row(csv_row, subscription) if subscription.present?
        @export.progress_tracker.increment_processed_items
      end
    end

    def map_user_row(csv_row, user)
      csv_row.cell :id, user.id
      csv_row.cell :lastname, user.lastname
      csv_row.cell :firstname, user.firstname
      csv_row.cell :email, user.email
      csv_row.cell :user_state, user.current_subscription.present?
    end

    def map_lesson_row(csv_row, lesson)
      csv_row.cell :lesson_location, lesson.location
      csv_row.cell :lesson_max_spots, lesson.max_spots
      csv_row.cell :lesson_number_of_member, LessonBooking.where(lesson_id: lesson.id).try(:count)
      csv_row.cell :lesson_start_at, I18n.l(lesson.start_at)
      csv_row.cell :lesson_room, lesson.room_text
      csv_row.cell :lesson_coach_name, lesson.coach_name
      csv_row.cell :lesson_activity, lesson.activity
    end

    def map_subscription_row(csv_row, subscription)
      csv_row.cell :subscription_start_at, I18n.l(subscription.start_at)
      csv_row.cell :subscription_end_at, subscription.decorate.try(:commitment_period)
    end
  end
end
