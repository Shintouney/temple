class SubscriptionPlan < ActiveRecord::Base
  include Product

  acts_as_list

  serialize :locations, Array

  has_many :subscriptions

  validates :locations, presence: true

  validates :commitment_period, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_nil: false }

  validates :discount_period, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_nil: false }

  REDUCED_PRICES = %i(discounted_price_ati discounted_price_te sponsorship_price_ati sponsorship_price_te)

  REDUCED_PRICES.each do |rp|
    validates rp, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  end

  validates :position, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  validates_absence_of REDUCED_PRICES, unless: :discount_period?
  validate :reduced_prices_uniqueness, if: :has_discount_period?
  validate :reduced_prices_are_greater_than_zero, if: :has_discount_period?

  scope :displayable, -> { where(displayable: true) }
  scope :not_expired, -> { where('expire_at IS NULL OR expire_at > ?', DateTime.now) }

  before_destroy :validate_has_no_subscriptions

  # Public: set default value for locations.
  #
  # Returns a Boolean.
  def locations
    attributes["locations"] ||= ['moliere', 'maillot', 'amelot']
  end

  # Public: Check if the SubscriptionPlan requires a code
  # to be ordered.
  #
  # Returns a Boolean.
  def require_code?
    code.present?
  end

  # Public: Determines if the SubscriptionPlan has expired.
  #
  # Returns a Boolean.
  def expired?
    expire_at.present? ? (expire_at < DateTime.now) : false
  end

  # Public: Determines if the SubscriptionPlan has at least one Subscription.
  #
  # Returns a Boolean.
  def has_subscriptions?
    subscriptions.any?
  end

  # Public: Check if the SubscriptionPlan has a discount period.
  #
  # Returns a Boolean.
  def has_discount_period?
    discount_period.present? && discount_period > 0
  end

  private

  def reduced_prices_uniqueness
    if discounted_price_ati.present? || discounted_price_te.present?
      require_discounted_prices_presence
    elsif sponsorship_price_ati.present? || sponsorship_price_te.present?
      require_sponsorship_prices_presence
    else
      errors.add(:discount_period, :must_have_reduced_price)
    end
  end

  def require_discounted_prices_presence
    errors.add(:discounted_price_ati, :blank) if discounted_price_ati.blank?
    errors.add(:discounted_price_te, :blank) if discounted_price_te.blank?

    errors.add(:sponsorship_price_ati, :present) if sponsorship_price_ati.present?
    errors.add(:sponsorship_price_te, :present) if sponsorship_price_te.present?
  end

  def require_sponsorship_prices_presence
    errors.add(:sponsorship_price_ati, :blank) if sponsorship_price_ati.blank?
    errors.add(:sponsorship_price_te, :blank) if sponsorship_price_te.blank?
  end

  def validate_has_no_subscriptions
    if has_subscriptions?
      errors.add(:base, :can_not_destroy_with_subscriptions)
      false
    end
  end

  def reduced_prices_are_greater_than_zero
    if discounted_price_ati && (discounted_price_ati > 0 && discounted_price_te == 0)
      errors.add(:discounted_price_te, :cannot_be_zero_when_price_ati_is_not_zero)
    end

    if sponsorship_price_ati && (sponsorship_price_ati > 0 && sponsorship_price_te == 0)
      errors.add(:sponsorship_price_te, :cannot_be_zero_when_price_ati_is_not_zero)
    end
  end
end
