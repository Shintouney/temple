class Profile < ActiveRecord::Base
  extend Enumerize

  belongs_to :user
  accepts_nested_attributes_for :user, update_only: true

  validates :user, presence: true

  serialize :sports_practiced, Array
  enumerize :sports_practiced, in: [:fitness, :tennis, :squash,
                                      :golf, :running, :dance,
                                      :collective_sports,
                                      :combats, :other, :none], multiple: true

  serialize :fitness_goals, Array
  enumerize :fitness_goals, in: [:improved_cardio, :build_up, :weight_loss], multiple: true

  serialize :boxing_disciplines_practiced, Array
  enumerize :boxing_disciplines_practiced, in: [:english, :french, :thai, :kickboxing], multiple: true

  serialize :boxing_disciplines_wished, Array
  enumerize :boxing_disciplines_wished, in: [:english, :french, :thai,
                                        :kickboxing, :self_defense, :dont_know], multiple: true

  serialize :attendance_periods, Array
  enumerize :attendance_periods, in: [:weeks, :weekends], multiple: true

  serialize :weekdays_attendance_hours, Array
  enumerize :weekdays_attendance_hours, in: [:before_nine_am, :between_nine_and_twelve_am,
                                              :between_twelve_and_two_pm, :between_two_and_six_pm,
                                              :between_six_and_nine_pm, :after_nine_pm], multiple: true

  serialize :weekend_attendance_hours, Array
  enumerize :weekend_attendance_hours, in: [:saturday_morning, :saturday_after_noon,
                                                :sunday_morning, :sunday_after_noon], multiple: true

  serialize :transportation_means, Array
  enumerize :transportation_means, in: [:on_foot, :public_transport, :own_vehicule], multiple: true

  enumerize :attendance_rate, in: [:once_a_week, :twice_per_week, :more_than_twice_per_week]
  enumerize :boxing_level, in: [:beginner, :medium, :confirmed]
end
