class NotificationSchedule < ActiveRecord::Base
  belongs_to :user
  belongs_to :lesson

  validates :user, :lesson, :scheduled_at, presence: true
end
