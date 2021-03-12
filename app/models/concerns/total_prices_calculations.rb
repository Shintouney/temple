module TotalPricesCalculations
  extend ActiveSupport::Concern

  # Public: Sums the product prices without taxes of each order_item
  # grouped by their taxes rates.
  #
  # Returns a Hash with the taxes_rate as the key and the price total as the value.
  def total_prices_te_by_taxes_rates
    order_items.reduce({}) do |total_prices, order_item|
      taxes_rate = order_item.product_taxes_rate.to_f

      total_prices[taxes_rate] ||= 0
      total_prices[taxes_rate] += order_item.product_price_te.to_f
      total_prices
    end
  end

  private

  def computed_total_price_ati
    total_prices_te_by_taxes_rates.sum { |taxes_rate, total| total * (1 + (taxes_rate / 100)) }.round(2)
  end

  def computed_total_price_te
    order_items.to_a.sum(&:product_price_te)
  end
end
