require 'rails_helper'

describe Profile do

  it { is_expected.to belong_to(:user) }

  describe "sports_practiced" do
    it do
      is_expected.to enumerize(:sports_practiced).in(:fitness, :tennis, :squash,
                                              :golf, :running, :dance,
                                              :collective_sports, :combats,
                                              :other, :none)
    end
  end

  describe "attendance_rate" do
    it { is_expected.to enumerize(:attendance_rate).in(:once_a_week, :twice_per_week, :more_than_twice_per_week) }
  end

  describe "fitness_goals" do
    it { is_expected.to enumerize(:fitness_goals).in(:improved_cardio, :build_up, :weight_loss) }
  end

  describe "boxing_disciplines_practiced" do
    it { is_expected.to enumerize(:boxing_disciplines_practiced).in(:english, :french, :thai, :kickboxing) }
  end

  describe "boxing_level" do
    it { is_expected.to enumerize(:boxing_level).in(:beginner, :medium, :confirmed) }
  end

  describe "boxing_disciplines_wished" do
    it { is_expected.to enumerize(:boxing_disciplines_wished).in(:english, :french, :thai, :kickboxing, :self_defense, :dont_know) }
  end

  describe "attendance_periods" do
    it { is_expected.to enumerize(:attendance_periods).in(:weeks, :weekends) }
  end

  describe "weekdays_attendance_hours" do
    it do
     is_expected.to enumerize(:weekdays_attendance_hours).in(:before_nine_am, :between_nine_and_twelve_am,
                                                    :between_twelve_and_two_pm, :between_two_and_six_pm,
                                                    :between_six_and_nine_pm, :after_nine_pm)
    end
  end

  describe "weekend_attendance_hours" do
    it { is_expected.to enumerize(:weekend_attendance_hours).in(:saturday_morning, :saturday_after_noon, :sunday_morning, :sunday_after_noon) }
  end

  describe "boxing_disciplines_wished" do
    it { is_expected.to enumerize(:transportation_means).in(:on_foot, :public_transport, :own_vehicule) }
  end

  describe "serialize fields" do
    it { is_expected.to serialize(:sports_practiced).as(Array) }
    it { is_expected.to serialize(:fitness_goals).as(Array) }
    it { is_expected.to serialize(:boxing_disciplines_practiced).as(Array) }
    it { is_expected.to serialize(:boxing_disciplines_wished).as(Array) }
    it { is_expected.to serialize(:attendance_periods).as(Array) }
    it { is_expected.to serialize(:weekdays_attendance_hours).as(Array) }
    it { is_expected.to serialize(:weekend_attendance_hours).as(Array) }
    it { is_expected.to serialize(:transportation_means).as(Array) }
  end
end
