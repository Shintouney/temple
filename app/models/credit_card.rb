class CreditCard < ActiveRecord::Base

  belongs_to :user

  validates :user, :number, :cvv, :expiration_month, :expiration_year, :brand, presence: true
  validates :expiration_month, inclusion: { in: 1..12 }

  attr_writer :activemerchant_credit_card

  # Public: Builds a CreditCard from the given activemerchant_credit_card.
  #
  # activemerchant_credit_card - An ActiveMerchant::Billing::CreditCard.
  #
  # Returns a CreditCard.
  def self.build_with_activemerchant_credit_card(activemerchant_credit_card, additional_params = {})
    raise ArgumentError unless activemerchant_credit_card.is_a?(ActiveMerchant::Billing::CreditCard)

    params = {
      firstname: activemerchant_credit_card.first_name,
      lastname: activemerchant_credit_card.last_name,
      number: activemerchant_credit_card.number,
      expiration_month: activemerchant_credit_card.month,
      expiration_year: activemerchant_credit_card.year,
      cvv: activemerchant_credit_card.verification_value,
      brand: activemerchant_credit_card.brand
    }.merge(additional_params)

    credit_card = CreditCard.new(params)
    credit_card.activemerchant_credit_card = activemerchant_credit_card
    credit_card
  end

  def number=(number)
    safe_write_attribute(:number, scramble_number(number))
  end

  def cvv=(cvv)
    safe_write_attribute(:cvv, encode_string(cvv))
  end

  def cvv
    read_attribute(:cvv) ? cipher.dec(read_attribute(:cvv)) : nil
  end

  def brand=(brand)
    safe_write_attribute(:brand, encode_string(brand))
  end

  def brand
    read_attribute(:brand) ? cipher.dec(read_attribute(:brand)) : nil
  end

  def safe_write_attribute(sym, value)
    if value.present?
      write_attribute(sym, value)
    else
      errors.add(sym, :missing)
    end
  end

  # Public: Get the equivalent of this CreditCard as an ActiveMerchant::Billing::CreditCard.
  #
  # Returns an ActiveMerchant::Billing::CreditCard.
  def to_activemerchant
    return @activemerchant_credit_card if @activemerchant_credit_card
    ActiveMerchant::Billing::CreditCard.new(
      first_name: firstname,
      last_name: lastname,
      number: number,
      month: expiration_month,
      year: expiration_year,
      verification_value: cvv,
      brand: brand
    )
  end

  private

  # Internal: Replaces all numbers in the given number with 'x' characters, except for the last 4 characters.
  #
  # number - The number to scramble.
  #
  # Returns the scrambled number a String.
  def scramble_number(number)
    return number unless number
    ('x' * (number.length - 4)) + number[-4, 4]
  end

  def encode_string(string)
    cipher.enc(string) if string
  end

  def cipher
    @cipher ||= Gibberish::AES.new(Settings.payment.credit_card_salt)
  end
end
