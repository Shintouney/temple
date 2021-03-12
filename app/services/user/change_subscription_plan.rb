class User
  class ChangeSubscriptionPlan

    attr_reader :subscription, :subscription_plan, :user

    def initialize(user, subscription_plan)
      @user = user
      @subscription_plan = subscription_plan
    end

    # Public: Processes the change of SubscriptionPlan for the given User.
    # A new, running Subscription record will be created
    # and the previous runnning Subscription will be replaced.
    def execute
      result = false

      user.transaction do
        stop_running_subscriptions

        result = create_subscription_and_handle_invoices 

        raise ActiveRecord::Rollback unless result
      end

      result
    end

    private

    def create_subscription_and_handle_invoices
      Rails.logger.info "===================INFO====================== Processing the creation of new subscription."
      result = create_subscription
      result = charge_and_create_invoices(result) if user.current_deferred_invoice.blank?
      result
    end

    def charge_and_create_invoices(result)
      result && charge_new_subscription && create_deferred_invoice
    end

    def stop_running_subscriptions
      user.subscriptions.with_state(:running).each(&:replace!)
    end

    def create_subscription
      create_subscription = Subscription::Create.new(user, subscription_plan)
      return false unless create_subscription.execute
      @subscription = create_subscription.subscription
      subscription.start!
    end

    def charge_new_subscription
      Rails.logger.info "===================INFO====================== Processing the creation of new invoice."
      invoice = Invoice.new(start_at: Date.today, end_at: Date.today, user: user)
      invoice.copy_user_attributes

      create_order_from_subscription = Order::CreateFromSubscription.new(invoice, subscription)
      return false unless create_order_from_subscription.execute

      invoice.wait_for_payment!
      Rails.logger.info "===================INFO====================== Charging new subscription."
      Invoice::Charge.new(invoice).execute
    end

    def create_deferred_invoice
      Rails.logger.info "===================INFO====================== Processing the creation of new deferred invoice."
      Invoice::Deferred::Create.new(user.reload).execute
    end
  end
end
