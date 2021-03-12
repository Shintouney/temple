# encoding: UTF-8
class Export < ActiveRecord::Base
  include AASM
  include StateMachineHelpers

  MAPPING_INVOICE_STATE_WITH_STATE_PARAMS = {
    'unfinished' => [:open, :pending_payment, :pending_payment_retry],
     'finished' => [:paid, :payment_not_needed],
     'special' => [:refunded, :canceled],
     'default' => [],
     'debit' => []
  }
  PATH = "tmp/exports"

  scope :in_progress, ->{ where(state: :in_progress) }

  aasm column: :state, whiny_transitions: false do
    state :in_progress, initial: true
    state :completed

    event :complete do
      transitions from: :in_progress, to: :completed
    end
  end

  after_create :create_progress_tracker
  before_destroy :remove_dependencies

  def invoices
    Invoice.with_state(MAPPING_INVOICE_STATE_WITH_STATE_PARAMS[subtype])
            .where("created_at >= ? AND created_at <= ?", date_start.beginning_of_day, date_end.end_of_day)
            .order(:created_at)
            .decorate
  end

  def lesson_bookings
    LessonBooking.where("created_at >= ? AND created_at <= ?", date_start.beginning_of_day, date_end.end_of_day)
                  .order(:created_at)
  end

  def payments
    Payment.with_state(:accepted)
                        .where("created_at >= ? AND created_at <= ?", date_start.beginning_of_day, date_end.end_of_day)
                        .order(:created_at)
  end

  def users
    _users = User.with_role(:user).includes(:subscriptions, :current_subscription).order(:created_at)
    if subtype == 'active'
      _users.active
    elsif subtype == 'inactive'
      _users.inactive
    else
      _users
    end
  end

  def filename
    case export_type
    when 'invoice'
      I18n.t('admin.exports.invoices.csv_filename', date: date_start.to_date.to_formatted_s(:db), state: subtype)
    when 'lesson_booking'
      I18n.t('admin.exports.lesson_booking.csv_filename', date: date_start.to_date.to_formatted_s(:db), state: subtype)
    when 'payment'
      I18n.t('admin.exports.payments.csv_filename', date: date_start.to_date.to_formatted_s(:db), state: subtype)
    when 'user'
      I18n.t("admin.exports.users.csv_filename.#{subtype}", date: Date.today.to_formatted_s(:db))
    end
  end

  def path
    "#{PATH}/#{filename}"
  end

  # Public: Associate a ProgressTracker based on name and exportable type.
  #
  # Returns the ProgressTracker instance.
  def progress_tracker
    @progress_tracker ||= ProgressTracker.new(export_type: export_type, subtype: subtype)
  end

  private

  def create_progress_tracker
    case export_type
    when 'invoice'
      size = invoices.size
    when 'lesson_booking'
      size = lesson_bookings.size
    when 'payment'
      size = payments.size
    when 'user'
      size = users.size
    end

    progress_tracker.create(size)
  end

  def remove_dependencies
    delete_progress_tracker
    delete_file
  end

  def delete_progress_tracker
    progress_tracker.delete if in_progress?
  end

  def delete_file
    File.delete(path) if File.exist?(path)
  end

end
