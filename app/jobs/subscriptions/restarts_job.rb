class Subscriptions::RestartsJob < ActiveJob::Base
  queue_as :default

  # Restart suspended subscription
  def perform(*args)
    ::Subscription.with_state(:temporarily_suspended).where("restart_date <= ?", ::Date.today).each do |subscription|
      ::AdminMailer.restart_subscription_fail(subscription.user.id).deliver_later unless ::User::RestartSubscription.new(subscription.user, subscription).execute
    end
    ::Subscription.with_state(:temporarily_suspended).where("restart_date <= ?", ::Date.tomorrow).each do |subscription|
      ::UserMailer.subscription_restart(subscription.user.id).deliver_later
    end
  end
end
