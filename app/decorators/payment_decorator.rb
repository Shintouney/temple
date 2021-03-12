class PaymentDecorator < ApplicationDecorator
  delegate_all

  # Public: The created_at attribute formatted as a String.
  #
  # Returns the localized String.
  def created_at
    I18n.l(object.created_at.to_date)
  end
end
