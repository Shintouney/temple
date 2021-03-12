class Lesson < ActiveRecord::Base
  include LessonAttributes

  belongs_to :lesson_template
  belongs_to :lesson_draft

  has_many :lesson_bookings
  has_many :notifications, as: :sourceable

  validates :start_at, :end_at, presence: true

  validate :end_at_after_start_at
  validate :lesson_must_be_upcoming, on: :create
  validate :lesson_must_not_overlap_lesson
  validate :max_spots_greater_or_equal_than_bookings

  scope :upcoming, -> { where(["lessons.start_at > ?", Time.now]) }

  # Public: Check if the Lesson is in the future.
  #
  # Returns a Boolean.
  def upcoming?
    start_at.present? && start_at > Time.now
  end

  # Public: The duration of the Lesson in seconds.
  #
  # Returns an Integer.
  def duration
    end_at - start_at
  end

  # Public: Determines if the Lesson overlaps another existing Lesson in the same room.
  #
  # Returns a Boolean.
  def overlaps?
    return false if room.nil? or start_at.nil? or end_at.nil? or location.nil?

    Lesson.where('location = ? AND room = ? AND ? < end_at AND start_at < ?', location, room.value.to_s, start_at, end_at).
           where.not(id: id).
           any?
  end

  def max_spots_greater_or_equal_than_bookings
    if lesson_bookings.any? && max_spots.present? && max_spots < lesson_bookings.size
      errors.add(:max_spots, :must_be_higher)
    end
  end

  # Public: Filter Lesson records by start and end dates.
  #
  # start_at_date - A start_at date String.
  # end_at_date   - An end_at date String.
  #
  # Returns an ActiveRecord::Relation of Lesson records.
  def self.within_period(start_at_date, end_at_date)
    start_at_date = start_at_date.present? ? Date.parse(start_at_date) : nil
    end_at_date = end_at_date.present? ? Date.parse(end_at_date) : nil

    if start_at_date.present? && end_at_date.present?
      where(["start_at >= ? AND start_at <= ?", start_at_date, end_at_date])
    elsif start_at_date.present?
      where(["start_at >= ?", start_at_date])
    elsif end_at_date.present?
      where(["start_at <= ?", end_at_date])
    end
  end

  # Public: Create a hash for json format
  #
  # lesson_attributes : [ :id, :start_at_hour, :end_at_hour, :activity, :room, :max_spots, :weekday ]
  # Retruns an Hash of attributes needed in json_format
  def self.json_format(lesson_attributes)
    {
      id: lesson_attributes[0],
      start: lesson_attributes[1],
      end: lesson_attributes[2],
      title: lesson_attributes[3],
      room: lesson_attributes[4],
      available: lesson_attributes[5].present? ? LessonBooking.where(lesson_id: lesson_attributes[0]).count < lesson_attributes[5] : false
    }
  end

  private

  def end_at_after_start_at
    return unless start_at.present? && end_at.present?

    if end_at <= start_at
      errors.add(:end_at, :must_be_after_start_at)
    elsif duration < MINIMUM_DURATION
      errors.add(:end_at, :must_be_longer)
    end
  end

  def lesson_must_be_upcoming
    errors.add(:start_at, :must_be_upcoming) unless upcoming?
  end

  def lesson_must_not_overlap_lesson
    errors.add(:room, :must_not_overlap) if overlaps?
  end
end
