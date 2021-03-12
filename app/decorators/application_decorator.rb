class ApplicationDecorator < Draper::Decorator
  # Public: Format and localize a price number.
  #
  #  price - The Float to be formatted.
  #
  # Returns the formatted price String.
  def formatted_price(price)
    h.number_to_currency(price)
  end

  def formatted_taxes_rate(rate = nil)
    rate ||= taxes_rate

    h.number_to_percentage(rate, precision: 2)
  end

  # Public: The created_at attribute formatted as a String.
  #
  # Returns the localized String.
  def created_at
    I18n.l(object.created_at)
  end
end
