class Subscriptions::CheckJob < ActiveJob::Base
  queue_as :default

  # Checking pending subscriptions. (Those users shall NOT have payments means)
  def perform
    users_hash = check_subscriptions
    ::ApplicationController.helpers.display_results(users_hash)
    ::AdminMailer.invalid_users(users_hash, :pending_subscription).deliver_later if users_hash.any?
  end

  private

  def check_subscriptions
    ::Subscription.with_state(:pending).reduce({}) do |a, sub|
      a[sub.user_id.to_s] = "Subscription n°#{sub.id} pending but its user has payment means" if sub.user.has_payment_means?
      a
    end
  end
end
