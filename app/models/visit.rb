class Visit < ActiveRecord::Base
  belongs_to :user

  belongs_to :checkin_scan, class_name: 'CardScan'
  belongs_to :checkout_scan, class_name: 'CardScan'

  validates :started_at, :user, :location, presence: true

  validates :user_id, uniqueness: true, if: :is_in_progress_and_user_has_visits_in_progress

  validate :ended_at_after_started_at

  scope :in_progress, -> { where(ended_at: nil) }
  scope :ended, -> { where('ended_at IS NOT NULL') }

  # Public: Determines if the Visit is in progress.
  # The Visit is in progress when ended_at is nil.
  #
  # Returns a Boolean.
  def in_progress?
    ended_at.nil?
  end

  # Public: Marks the Visit as ended at the current time.
  # Only Visits in progress can be finished.
  #
  # checkout_scan - An optional CardScan record to save as the checkout scan.
  # ended_at - An optional end Time. If not provided, will be equal to the scanned_at
  #            value of the checkout_scan or the current Time
  #
  # Returns the result of the operation as a Boolean.
  def finish!(checkout_scan = nil, ended_at = nil)
    return false unless in_progress?

    ended_at ||= checkout_scan ? checkout_scan.scanned_at : DateTime.now
    self.update_attributes(ended_at: ended_at, checkout_scan: checkout_scan)
  end

  private

  def is_in_progress_and_user_has_visits_in_progress
    if in_progress? and user.present? and user.visits.in_progress.any?
      errors.add(:base, :visit_in_progress_for_user)
    end
  end

  def ended_at_after_started_at
    return unless started_at.present? && ended_at.present?

    if ended_at <= started_at
      errors.add(:ended_at, :must_be_after_started_at)
    end
  end
end
