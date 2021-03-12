class SubscriptionPlanDecorator < ApplicationDecorator
  delegate_all

  # Public: The human-formatted price_ati.
  #
  # Returns a String.
  def price_ati
    formatted_price(object.price_ati)
  end

  # Public: The human-formatted discounted_price_ati.
  #
  # Returns a String.
  def discounted_price_ati
    formatted_price(object.discounted_price_ati)
  end

  # Public: The human-formatted discounted_price_te.
  #
  # Returns a String.
  def discounted_price_te
    formatted_price(object.discounted_price_te)
  end

  # Public: The human-formatted sponsorship_price_ati.
  #
  # Returns a String.
  def sponsorship_price_ati
    formatted_price(object.sponsorship_price_ati)
  end

  # Public: The human-formatted sponsorship_price_te.
  #
  # Returns a String.
  def sponsorship_price_te
    formatted_price(object.sponsorship_price_te)
  end

  # Public: Determines if a discounted_price_ati is currently applied.
  #
  # Returns a Boolean.
  def discount_price_applied?
    has_discount_period? and discounted_price_ati.present?
  end

  # Public: The human-formatted price currently displayed.
  #
  # Returns a String.
  def displayed_price_ati
    discount_price_applied? ? discounted_price_ati : price_ati
  end

  # Public: Determines if the SubscriptionPlan's edition is restricted.
  #
  # Returns a Boolean.
  def edit_restricted?
    object.has_subscriptions?
  end
end
