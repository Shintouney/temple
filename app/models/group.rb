class Group < ActiveRecord::Base
  extend Enumerize


  has_and_belongs_to_many :users

  validates :name, :users, presence: true

  serialize :filter_between_age, Array
  serialize :filter_gender, Array
  serialize :filter_postal_code, Array
  serialize :filter_with_subscription, Array
  serialize :filter_created_since, Array
  serialize :filter_usual_room, Array
  serialize :filter_usual_activity, Array
  serialize :filter_frequencies, Array
  serialize :filter_last_booking_dates, Array
  serialize :filter_last_visite_dates, Array
  serialize :filter_last_article, Array
end
