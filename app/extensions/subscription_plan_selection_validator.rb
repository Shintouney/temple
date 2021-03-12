class SubscriptionPlanSelectionValidator
  include ActiveModel::Model

  attr_accessor :subscription_plan, :code
  attr_reader :sponsor

  validates_presence_of :subscription_plan
  validate :code_presence

  private

  def code_presence
    return unless @subscription_plan.try(:require_code?) && @code != @subscription_plan.code
    errors.add :code, :invalid_match
  end
end
