class User
  class RestartSubscription

    attr_reader :subscription, :user, :invoice, :order

    def initialize(user, subscription)
      @user = user
      @subscription = subscription
    end

    def execute
      ActiveRecord::Base.transaction do
        subscription.restart!
        subscription.update_attributes!(start_at: Date.today.advance(days: subscription.grace_period_in_days))

        @old_invoice = user.current_deferred_invoice
        next_invoice_is_ok = Invoice::Deferred::Create.new(user.reload).execute
        move_current_order_to_new_invoice

        subscription.update_attributes!(end_of_commitment_date: subscription.end_of_commitment)

        next_invoice_is_ok
      end
    end

    private

    def create_invoice
      @invoice = Invoice.new( start_at: Date.today,
                              end_at: Date.today,
                              user: user,
                              next_payment_at: Date.today,
                              subscription_period_start_at: Date.today,
                              subscription_period_end_at: Date.today + Subscription::PERIODICITY)
      invoice.copy_user_attributes
    end

    def create_order
      create_order_from_subscription = Order::CreateFromSubscription.new(invoice, subscription)
      return false unless create_order_from_subscription.execute
      @order = create_order_from_subscription.order
    end

    def move_current_order_to_new_invoice
      return if @old_invoice.nil?
      @new_invoice = user.current_deferred_invoice
      @old_invoice.orders.each { |row| row.update_attributes!(invoice_id: @new_invoice.id) }
    end
  end
end
