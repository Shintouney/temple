class VisitDecorator < ApplicationDecorator
  delegate_all

  decorates_association :user

  # Public: A CSS class for the item to use in panels components.
  #
  # Returns a String.
  def panel_class
    "panel-#{css_color_class}"
  end

  # Public: An HTML id for the item to use in panels components.
  #
  # Returns a String.
  def panel_id
    "user_visit_#{visit.user.id}"
  end

  private

  def css_color_class
    'success'
  end
end
