class CreditCardDecorator < ApplicationDecorator
  delegate_all

  # Public: The CreditCard's owner name.
  #
  # Returns a String.
  def owner_name
    "#{firstname} #{lastname}"
  end

  # Public: The CreditCard's expiration date.
  #         Adds a leading zero to the month if needed.
  #
  # Returns a String.
  def expiration_date
    "#{expiration_month.to_s.rjust(2, '0')} / #{expiration_year}"
  end
end
