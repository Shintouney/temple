class CardScan < ActiveRecord::Base
  extend Enumerize

  SCAN_POINTS = {
    building_door_moliere: 928,
    front_door_moliere: 929,
    bar_entrance_moliere: 930,
    bar_exit_moliere: 931,
    building_door_maillot: 2877,
    front_door_maillot: 2876,
    bar_entrance_maillot: 2874,
    bar_exit_maillot: 2875,
    building_door_amelot: 3781,
    front_door_amelot: 3780,
    bar_entrance_amelot: 3782,
    bar_exit_amelot: 3783,
  }

  CARD_REFERENCE_FORMAT = /\A[\dA-F]{16}\z/

  belongs_to :user

  has_one :visit_as_checkin_scan, class_name: 'Visit', foreign_key: 'checkin_scan_id'
  has_one :visit_as_checkout_scan, class_name: 'Visit', foreign_key: 'checkout_scan_id'

  enumerize :scan_point, in: SCAN_POINTS, predicates: { prefix: true }

  validates :card_reference, :scanned_at, :scan_point, :user, presence: true
  validates :accepted, inclusion: { in: [true, false] }

  validates :card_reference, format: CARD_REFERENCE_FORMAT, allow_blank: true

  before_save :build_location

  private
  def build_location
    if scan_point_building_door_moliere? || scan_point_front_door_moliere? || scan_point_bar_entrance_moliere? || scan_point_bar_exit_moliere?
      self.location ||= 'moliere'
    elsif scan_point_building_door_maillot? || scan_point_front_door_maillot? || scan_point_bar_entrance_maillot? || scan_point_bar_exit_maillot?
      self.location ||= 'maillot'
    else
      self.location ||= 'amelot'
    end
  end
end
