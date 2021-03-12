class NotificationSchedules::SuspendedSubscriptionJob < ActiveJob::Base
  queue_as :default

  # Suspend subscription temporarily
  def perform
    ::SuspendedSubscriptionSchedule.where("scheduled_at <= ?", ::Date.today).each do |suspended_subscription_schedule|
      subscription = suspended_subscription_schedule.user.current_subscription
      if subscription.present?
        update_subscription(subscription, suspended_subscription_schedule)
      else
        suspended_subscription_schedule.destroy
      end
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
      ::AdminMailer.suspended_subscription(suspended_subscription_schedule.user).deliver_later
    end
  end

  def compute_grace_period(subscription)
    if has_grace_period_overlay?(subscription)
      (subscription.start_at - ::Date.today).to_i
    else
      last_open_invoice = subscription.user.invoices.with_state(:open).last
      last_open_invoice.present? ? ((last_open_invoice.next_payment_at - ::Date.today).to_i - 1) : 0
    end
  end

  def has_grace_period_overlay?(subscription)
    subscription.restart_date.present? && subscription.grace_period_in_days.present? && subscription.start_at > ::Date.today
  end
end
