module Product
  extend ActiveSupport::Concern

  included do
    validates :name, presence: true

    validates :price_ati, presence: true
    validates :price_ati, numericality: {greater_than_or_equal_to: 0}

    validates :price_te, presence: true
    validates :price_te, numericality: {greater_than_or_equal_to: 0}

    validates :taxes_rate, presence: true
    validates :taxes_rate, numericality: {greater_than_or_equal_to: 0}

    validate :price_te_is_greater_than_zero
  end

  private

  def price_te_is_greater_than_zero
    return true unless price_ati

    if price_ati > 0 && price_te == 0
      errors.add(:price_te, :cannot_be_zero_when_price_ati_is_not_zero)
    end
  end
end
