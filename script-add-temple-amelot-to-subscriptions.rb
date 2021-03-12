SubscriptionPlan.all.each do |subscription_plan|
  ActiveRecord::Base.transaction do
    puts "subscription_plan id #{subscription_plan.id}"
    subscription_locations = (subscription_plan.locations.to_a.reject(&:empty?).map(&:downcase) | ["amelot"])
    subscription_plan.subscriptions.each do |subscription|
      puts "> subscription id #{subscription.id}"
      subscription.locations = subscription_locations
      subscription.save(validate: false) # because of discount_period of some invalid
    end
    subscription_plan.update!(locations: subscription_locations)
  end
end