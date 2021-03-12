class SuspendedSubscriptionSchedule < ActiveRecord::Base
  belongs_to :user

  validates :user, :scheduled_at, :subscription_restart_date, presence: true

  validate :subscription_restart_date_greater_than_scheduled_at

  private

  def subscription_restart_date_greater_than_scheduled_at
  	return if subscription_restart_date.blank? || scheduled_at.blank?
  	errors.add(:subscription_restart_date, :must_be_greater_than_scheduled_at) if subscription_restart_date < scheduled_at
  end
end
