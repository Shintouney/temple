class Payment
  class Processor
    include ActiveMerchantGatewayMethods

    attr_reader :payment, :activemerchant_credit_card

    # Public: Initializes ProcessPayment
    #
    # payment - A pending payment
    #
    # Raises ArgumentError if payment is not awaiting transaction.
    def initialize(payment)
      @payment = payment
      return if payment.user.payment_mode.none?
      @paybox_user_reference = payment.user.paybox_user_reference
      @activemerchant_credit_card = payment.credit_card.present? ? payment.credit_card.to_activemerchant : nil

      raise ArgumentError unless payment.transaction_pending?
    end

    # Public: Processes the payment for the order.
    #
    # Returns a Boolean, true if the payment was accepted, false otherwise.
    def execute
      payment.compute_price and payment.save!

      @mandate = @payment.user.mandates.ready.last
      if ((payment.user.payment_mode.sepa? && @mandate.nil?) || (payment.user.payment_mode.cb? && !payment.credit_card.present?))
        payment.decline!
        return false
      end

      begin
        if payment.user.payment_mode.sepa?
          process_slimpay_payment
        elsif payment.user.payment_mode.cb?
          process_paybox_payment
        end
      rescue ActiveMerchant::ConnectionError => e
        (AdminMailer.error("ActiveMerchant::ConnectionError", e).deliver_later rescue nil)
        raise e
      end
    end

    private

    def process_paybox_payment
      if payment.credit_card.paybox_reference.present?
        process_result = process_payment
      else
        process_result = create_profile_and_process_payment
      end
      process_result == true ? payment.accept! : payment.decline!
      process_result
    end

    def process_slimpay_payment
      slimpay_debits = Slimpay::DirectDebit.new
      result_hash = JSON.parse(slimpay_debits.make_payment(slimpay_debit_hash))
      return payment.decline! if Payment::SLIMPAY_REJECTIONS.include?(result_hash['executionStatus'])
      @payment.update_attributes!(slimpay_direct_debit_id: result_hash['id'], slimpay_status: result_hash['executionStatus'])
      payment.wait_slimpay_confirmation!
    end

    def slimpay_debit_hash
      {
        creditor: {
          reference: Slimpay.configuration.creditor_reference
        },
        mandate: {
          rum: @mandate.slimpay_rum
        },
        amount: @payment.price.round(2),
        label: @payment.invoices.first.order_items.map(&:product_name).join(', '),
        paymentReference: @payment.id
      }
    end

    attr_reader :paybox_user_reference

    # Internal: Creates a Paybox profile, updates the user and payment,
    #           and makes a payment capture with the payment_amount.
    #
    # Returns the operation result as a Boolean, true if succeeded, false otherwise.
    def create_profile_and_process_payment
      response = gateway.create_payment_profile(100,
                                                activemerchant_credit_card,
                                                user_reference: paybox_user_reference)
      update_payment_and_credit_card_with_response(response)

      if response.success?
        process_payment
      else
        false
      end
    end

    # Internal: Makes a purchase with the payment_amount and updates user and order.
    #
    # Returns the operation result as a Boolean, true if succeeded, false otherwise.
    def process_payment
      response = gateway.purchase(payment_price, activemerchant_credit_card,
                                  user_reference: paybox_user_reference,
                                  order_id: payment.id,
                                  credit_card_reference: payment.credit_card.paybox_reference
                                 )
      update_payment_and_credit_card_with_response(response)
      response.success?
    end

    def payment_price
      (payment.price * 100).to_i
    end

    def update_payment_and_credit_card_with_response(response)
      payment.credit_card.update_attributes!(paybox_reference: response.params['credit_card_reference'])
      payment.update_attributes!(paybox_transaction: response.params['authorization'],
                                 comment: response.params['commentaire'])
    end
  end
end
