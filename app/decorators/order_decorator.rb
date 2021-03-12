class OrderDecorator < ApplicationDecorator
  delegate_all

  decorates_association :order_items
  decorates_association :invoice

  # Public: The translated state.
  #
  # Returns a String.
  def state
    if object.invoice.present?
      if object.invoice.open?
        Invoice.human_state_name(:pending_payment)
      else
        object.invoice.human_state_name
      end
    end
  end

  # Public: a human representation of the Order id.
  #
  # Returns a String.
  def reference
    "##{id}"
  end

  # Public: The human-formatted computed_total_price_ati.
  #
  # Returns a String.
  def computed_total_price_ati
    formatted_price(object.computed_total_price_ati)
  end

  # Public: The human-formatted computed_total_price_te.
  #
  # Returns a String.
  def computed_total_price_te
    formatted_price(object.computed_total_price_te)
  end

  # Public: Generates an Array representing the taxes amounts,
  # with the first keys as the taxes rates formatted as a localized String
  # and the second keys as the localized total price for the tax rate.
  #
  # Returns a 2-dimensional Array.
  def total_taxes_amounts
    order.total_prices_te_by_taxes_rates.map do |taxes_rate, price_without_taxes|
      tax_amount = price_without_taxes.to_f * (taxes_rate / 100)

      [formatted_taxes_rate(taxes_rate), formatted_price(tax_amount)]
    end
  end
end
