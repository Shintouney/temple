module LessonAttributes
  extend ActiveSupport::Concern

  MINIMUM_DURATION = 30.minutes

  included do
    validates :room, :coach_name, :activity, presence: true

    validates :max_spots, allow_blank: true, numericality: {greater_than_or_equal_to: 0, only_integer: true}

    extend Enumerize
    enumerize :room, in: { ring: 1, training: 2, arsenal: 3, ring_no_opposition: 4, ring_no_opposition_advanced: 5, ring_feet_and_fist: 6 }
    enumerize :location, in: { moliere: "moliere", maillot: "maillot", amelot: "amelot" }, scope: :located
  end
end
