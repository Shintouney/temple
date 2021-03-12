class SubscriptionDecorator < ApplicationDecorator
  delegate_all

  delegate :name, to: :subscription_plan, prefix: true

  # Public: The human-formatted start_at attribute.
  #
  # Returns the localized String.
  def start_at
    I18n.l(object.start_at)
  end

  # Public: The human-formatted date for the end of the commitment period attribute.
  #
  # Returns the localized String.
  def commitment_period
    if object.restart_date.present? && object.end_of_commitment_date.present?
      I18n.l(object.end_of_commitment_date.advance(months: 1))
    else
      object.commitment_period_origin
    end
  end
end
