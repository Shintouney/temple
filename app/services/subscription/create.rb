class Subscription
  class Create

    attr_reader :subscription, :subscription_plan, :user

    def initialize(user, subscription_plan)
      @subscription_plan = subscription_plan
      @user = user
    end

    def execute
      start_at = create_start_at
      @subscription = Subscription.new(user: user,
                                       subscription_plan: subscription_plan,
                                       commitment_period: subscription_plan.commitment_period,
                                       discount_period: subscription_plan_discount_period,
                                       start_at: start_at,
                                       locations: subscription_plan.locations)
      @subscription.save!
    end

    private

    def create_start_at
      return Date.today if user.subscriptions.blank?

      last_subscription = user.subscriptions.to_a.sort_by(&:id).last

      return last_subscription.try(:start_at) if !last_subscription.canceled? ||
                                                   user.invoices.with_state(:open).any?

      Date.today
    end

    def subscription_plan_discount_period
      return subscription_plan.discount_period if user.current_subscription.nil?
      return 0 if user.sponsor.present? && already_has_discounted_subscription?
      return 0 unless subscription_plan.discount_period > 0

      if (subscription_plan.discounted_price_ati.present? || user.sponsor.present?)
        subscription_plan.discount_period
      else
        0
      end
    end

    def already_has_discounted_subscription?
      user.subscriptions.to_a.delete_if{|sub| sub == subscription }.select{ |sub_select| sub_select.subscription_plan.discount_period > 0 }.any?
    end
  end
end
