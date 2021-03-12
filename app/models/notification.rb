class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :sourceable, polymorphic: true

  validates_presence_of :user_id, :sourceable_id, :sourceable_type

  validates_uniqueness_of :user_id, scope: [:sourceable_id, :sourceable_type]

  scope :type_lesson, -> { where(sourceable_type: 'Lesson') }
end
