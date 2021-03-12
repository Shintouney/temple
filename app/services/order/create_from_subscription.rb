class Order
  class CreateFromSubscription

    attr_reader :subscription, :subscription_plan, :order, :user, :invoice

    def initialize(invoice, subscription)
      @subscription = subscription
      @subscription_plan = subscription.subscription_plan
      @user = subscription.user
      @invoice = invoice
      @order = Order.new(user: user, invoice: invoice)
    end

    def execute
      result = false

      Order.transaction do
        order.save!

        add_product_to_order = Order::AddProduct.new(order, subscription_plan, subscription_price_ati, subscription_price_te)

        result = add_product_to_order.execute && update_subscription_period_attributes

        raise ActiveRecord::Rollback unless result
      end

      result
    end

    private

    def update_subscription_period_attributes
      if subscription.discount_running?
        subscription.discount_period = (subscription.subscription_plan.discount_period - ((Date.today.year * 12 + Date.today.month) - (subscription.created_at.to_date.year * 12 + subscription.created_at.to_date.month))) - 1
      end

      subscription.commitment_period -= 1 if subscription.commitment_running?

      subscription.save!
    end

    def subscription_price_te
      if subscription.discount_running?
        subscription_plan.discounted_price_te || subscription_plan.sponsorship_price_te
      else
        subscription_plan.price_te
      end
    end

    def subscription_price_ati
      if subscription.discount_running?
        subscription_plan.discounted_price_ati || subscription_plan.sponsorship_price_ati
      else
        subscription_plan.price_ati
      end
    end
  end
end
