namespace :subscriptions do
  desc "Check pending subscriptions"
  task check: :environment do
    puts "Checking pending subscriptions. (Those users shall NOT have payments means)"
    users_hash = check_subscriptions
    display_results(users_hash)
    AdminMailer.invalid_users(users_hash, :pending_subscription).deliver_later if users_hash.any?
  end

  desc "Suspend subscription temporarily"
  task suspended_subscription_scheduler: :environment do
    SuspendedSubscriptionSchedule.where("scheduled_at <= ?", Date.today).each do |suspended_subscription_schedule|
      subscription = suspended_subscription_schedule.user.current_subscription
      if subscription.present?
        update_subscription(subscription, suspended_subscription_schedule)
      else
        suspended_subscription_schedule.destroy
      end
    end
  end

  desc "Restart suspended subscription"
  task restart: :environment do
    Subscription.with_state(:temporarily_suspended).where("restart_date <= ?", Date.today).each do |subscription|
      AdminMailer.restart_subscription_fail(subscription.user).deliver_later unless User::RestartSubscription.new(subscription.user, subscription).execute
    end
  end

  desc "Restart suspended subscription mailer"
  task restart_mailer: :environment do
    Subscription.with_state(:temporarily_suspended).where("restart_date <= ?", Date.tomorrow).each do |subscription|
      UserMailer.subscription_restart(subscription.user.id).deliver_later
    end
  end

  private

  def update_subscription(subscription, suspended_subscription_schedule)
    subscription.update_attributes(restart_date: suspended_subscription_schedule.subscription_restart_date,
                                  grace_period_in_days: compute_grace_period(subscription))
    if subscription.temporarily_suspend!
      #UserMailer.subscription_suspended(suspended_subscription_schedule.user.id, suspended_subscription_schedule.subscription_restart_date).deliver_later
      suspended_subscription_schedule.destroy
    else
      AdminMailer.suspended_subscription(suspended_subscription_schedule.user).deliver_later
    end
  end

  def compute_grace_period(subscription)
    if has_grace_period_overlay?(subscription)
      (subscription.start_at - Date.today).to_i
    else
      (subscription.user.invoices.with_state(:open).last.next_payment_at - Date.today).to_i - 1
    end
  end

  def has_grace_period_overlay?(subscription)
    subscription.restart_date.present? && subscription.grace_period_in_days.present? && subscription.start_at > Date.today
  end

  def check_subscriptions
    Subscription.with_state(:pending).reduce({}) do |a, sub|
      a[sub.user_id.to_s] = "Subscription n°#{sub.id} pending but its user has payment means" if sub.user.has_payment_means?
      a
    end
  end
end
