class OrderItemDecorator < ApplicationDecorator
  delegate_all

  def product_price_ati
    formatted_price(object.product_price_ati)
  end

  def product_price_te
    formatted_price(object.product_price_te)
  end

  def product_taxes_rate
    formatted_taxes_rate(object.product_taxes_rate)
  end

end
