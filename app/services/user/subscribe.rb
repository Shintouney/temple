class User
  class Subscribe
    attr_reader :user, :order, :activemerchant_credit_card, :subscription, :subscription_plan, :invoice

    def initialize(user, subscription_plan, activemerchant_credit_card)
      @user = user
      @subscription_plan = subscription_plan
      @activemerchant_credit_card = activemerchant_credit_card

      raise ArgumentError if @subscription_plan.expired?
    end

    # Public: Processes the subscription of a user.
    #
    # Returns a Boolean, true if the operation was successful, false otherwise.
    def execute
      if activemerchant_credit_card.nil?
        # Client created by admin
        create_subscription
        user.update_attribute :card_access, User.card_access.find_value(:forbidden).value
        subscription.update_attribute :start_at, Date.today if subscription.present?
        UserMailer.welcome(user.id).deliver_later
      else
        # Subscription by Client.
        process_payment_workflow
        return false unless subscription.present? && user.persisted?
        finalize_user_subscription
      end
    end

    private

    def process_payment_workflow
      return if user.current_deferred_invoice.present?
      user.transaction do
        create_related_records
        invoice.wait_for_payment!
        set_paybox_user_reference
        @charge_invoice = Invoice::Charge.new(invoice).execute
        raise ActiveRecord::Rollback unless @charge_invoice
      end
    end

    def create_related_records
      create_user_credit_card
      raise ActiveRecord::Rollback unless create_invoice && create_subscription && create_order
    end

    def create_user_credit_card
      credit_card = CreditCard.build_with_activemerchant_credit_card(activemerchant_credit_card, user: user)
      credit_card.save!
      user.current_credit_card = credit_card
      user.update_attribute :payment_mode, 'cb'
    end

    def create_invoice
      @invoice = Invoice.new(start_at: Date.today, end_at: Date.today, user: user)
      invoice.copy_user_attributes
    end

    def create_subscription
      create_subscription = Subscription::Create.new(user, subscription_plan)
      return false unless create_subscription.execute
      @subscription = create_subscription.subscription
    end

    def create_order
      create_order_from_subscription = Order::CreateFromSubscription.new(invoice, subscription)
      return false unless create_order_from_subscription.execute
      @order = create_order_from_subscription.order
    end

    def set_paybox_user_reference
      user.paybox_user_reference = [
        "TEMPLE",
        Settings.user.paybox_reference_prefix,
        sprintf("%05d", user.id),
        user.created_at.to_time.to_i
      ].join('#')
      user.save!
    end

    def finalize_user_subscription
      return false if subscription.nil? || !subscription.persisted? || user.nil?
      subscription.start!
      @old_invoice = user.current_deferred_invoice
      next_invoice_is_ok = Invoice::Deferred::Create.new(user.reload).execute
      move_current_order_to_new_invoice
      subscription.update_attribute :start_at, Date.today if subscription.present?
      UserMailer.welcome(user.id).deliver_later if next_invoice_is_ok
      next_invoice_is_ok
    end

    def move_current_order_to_new_invoice
      return if @old_invoice.nil?
      @new_invoice = user.current_deferred_invoice
      @old_invoice.orders.update_all(invoice_id: @new_invoice.id)
    end
  end
end
