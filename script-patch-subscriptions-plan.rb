ActiveRecord::Base.transaction do
  subscription_plan = SubscriptionPlan.find(32)
  to_remove = ["amelot"]
  to_add = []
  subscription_plan.subscriptions.each do |subscription|
    next unless subscription.user.present?
    subscription.locations -= to_remove
    subscription.locations |= to_add
    subscription.locations = subscription.locations.reject(&:empty?).map(&:downcase)
    subscription.save!
  end
  subscription_plan.locations -= to_remove
  subscription_plan.locations |= to_add
  subscription_plan.save!
end
