class CreditCard
  class Create
    include ActiveMerchantGatewayMethods

    attr_reader :user, :activemerchant_credit_card, :credit_card, :subscription

    def initialize(user, activemerchant_credit_card)
      @user = user
      @activemerchant_credit_card = activemerchant_credit_card
      @subscription = user.subscriptions.with_state(:running).first
    end

    def execute
      @credit_card = CreditCard.build_with_activemerchant_credit_card(activemerchant_credit_card, user: user)

      return new_paybox_profile unless user.credit_cards.any?

      if update_credit_card_reference
        user.current_credit_card = credit_card
        user.payment_mode = :cb
        user.save && credit_card.save
      else
        false
      end
    end

    private
    def new_paybox_profile
      result = true
      user.transaction do
        unless create_paybox_profile
          gateway.destroy_payment_profile(100, user_reference: user.paybox_user_reference)
          result = false
          raise ActiveRecord::Rollback
        end
      end
      result
    end

    def create_paybox_profile
      set_paybox_user_reference

      response = gateway.create_payment_profile(100,
                                        activemerchant_credit_card,
                                        user_reference: user.paybox_user_reference)
      if response.success?
        credit_card.save!
        user.current_credit_card = credit_card
        user.payment_mode = :cb
        user.save!
        credit_card.update_attributes!(paybox_reference: response.params['credit_card_reference'])
        pay_and_start_subscription
      else
        activemerchant_credit_card.message_from_paybox = response.message
        false
      end
    end

    def pay_and_start_subscription
      if make_first_payment == true
        user.subscriptions.pending.last.start!
        set_paybox_user_reference
        Invoice::Deferred::Create.new(user.reload).execute
      else
        false
      end
    end

    def make_first_payment
      invoice = Invoice.new(start_at: Date.today, end_at: Date.today, user: user)
      invoice.copy_user_attributes
      last_pending_subscription = user.subscriptions.with_state(:pending).last
      if last_pending_subscription.present?
        Order::CreateFromSubscription.new(invoice, last_pending_subscription).execute
        invoice.wait_for_payment!
        Invoice::Charge.new(invoice).execute
      end
    end

    def update_credit_card_reference
      response = gateway.update_payment_profile(100,
                                                activemerchant_credit_card,
                                                user_reference: user.paybox_user_reference)
      if response.success?
        credit_card.paybox_reference = response.params['credit_card_reference']
      else
        activemerchant_credit_card.message_from_paybox = response.message
        false
      end
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
  end
end
