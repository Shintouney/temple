class LessonBooking < ActiveRecord::Base
  belongs_to :lesson
  belongs_to :user

  validates :lesson, :user, presence: true

  validate :lesson_spots_available, on: :create
  validate :user_has_card_access, on: :create
  validate :user_has_upcoming_lessons, on: :create
  validate :lesson_is_upcoming, on: :create
  validates :user_id, uniqueness: { scope: :lesson_id }, on: :create

  scope :upcoming, -> { joins(:lesson).merge(Lesson.upcoming) }

  def bookable?
    lesson_spots_available
    user_has_card_access
    lesson_is_upcoming
    #user_has_access_to_location
    has_valid_subscription
    errors.blank?
  end

  private

  def has_valid_subscription
    if user.current_subscription.nil?
      errors.add(:base, "user has not a valid subscription")
    end
  end

  def user_has_access_to_location
    return if user.nil? || user.subscriptions.last.locations.include?(lesson.location)
    errors.add(:base, :user_has_forbidden_access_to_location)
  end

  def lesson_spots_available
    return unless lesson.present? && lesson.max_spots.present?

    if lesson.lesson_bookings.reject { |lesson_booking| lesson_booking == self }.size >= lesson.max_spots
      errors.add(:base, :max_spots_reached)
    end
  end

  def user_has_card_access
    return if user.nil? || user.card_access_authorized?
    errors.add(:base, :user_has_forbidden_access)
  end

  def user_has_upcoming_lessons
    return unless user.present? && user.has_upcoming_lessons?
    errors.add(:base, :user_has_upcoming_lessons)
  end

  def lesson_is_upcoming
    return if lesson.nil? || lesson.upcoming?
    errors.add(:base, :lesson_is_not_upcoming)
  end
end
