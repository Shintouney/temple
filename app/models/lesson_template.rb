class LessonTemplate < ActiveRecord::Base
  include LessonAttributes

  has_many :lessons, dependent: :nullify

  validates :weekday, :start_at_hour, :end_at_hour, presence: true

  serialize :start_at_hour, Tod::TimeOfDay
  serialize :end_at_hour, Tod::TimeOfDay

  validate :end_at_hour_after_start_at_hour

  # Public: The duration of the LessonTemplate in seconds.
  #
  # Returns an Integer.
  def duration
    Shift.new(start_at_hour, end_at_hour).duration
  end

  # Public: Assign a value to start_at_hour after trying to convert it to
  # a TimeOfDay object.
  #
  # Returns the provided value.
  def start_at_hour=(value)
    write_attribute(:start_at_hour, (Tod::TimeOfDay.parse(value) rescue value))
  end

  # Public: Assign a value to end_at_hour after trying to convert it to
  # a TimeOfDay object.
  #
  # Returns the provided value.
  def end_at_hour=(value)
    write_attribute(:end_at_hour, (Tod::TimeOfDay.parse(value) rescue value))
  end

  # Public: Create a hash for json format
  #
  # lesson_attributes : [ :id, :start_at_hour, :end_at_hour, :activity, :room, :max_spots, :weekday ]
  # Retruns an Hash of attributes needed in json_format
  def self.json_format(lesson_attributes)
    {
      id: lesson_attributes[0],
      start: Time.now.beginning_of_week + ((lesson_attributes[6] - 1).days) + lesson_attributes[1].to_i,
      end: Time.now.beginning_of_week + ((lesson_attributes[6] - 1).days) + lesson_attributes[2].to_i,
      title: lesson_attributes[3],
      room: lesson_attributes[4],
      available: true
    }
  end

  private

  def end_at_hour_after_start_at_hour
    return unless start_at_hour.present? && end_at_hour.present?

    if end_at_hour <= start_at_hour
      errors.add(:end_at_hour, :must_be_after_start_at_hour)
    elsif duration < MINIMUM_DURATION
      errors.add(:end_at_hour, :must_be_longer)
    end
  end
end
