class Invoice
  module Deferred
    class Charge

      RETRY_PAYMENT_DELAY = 15.days

      attr_reader :invoice, :payment, :subscription, :user

      def initialize(invoice)
        @invoice = invoice
        raise ArgumentError.new("invoice cannot be nil") unless @invoice.present?

        @user = @invoice.user
        raise ArgumentError.new("invoice ##{@invoice.try(:id)} is not related to a user") unless @user.present?

        @subscription = @user.current_subscription
      end

      def execute
        charge_invoice

        invoice.paid?
      end

      private

      def charge_invoice
        charge_invoice = Invoice::Charge.new(invoice)
        @payment = charge_invoice.payment

        if charge_invoice.execute
          authorize_user_card_access
        elsif invoice.pending_payment_retry?
          handle_failed_payment_retry
        else
          handle_failed_payment
        end
      end

      def handle_failed_payment
        invoice.wait_for_payment_retry!

        invoice.update_attributes(next_payment_at: invoice.next_payment_at + RETRY_PAYMENT_DELAY)
      end

      def handle_failed_payment_retry
        invoice.wait_for_payment!
        forbid_user_card_access

        AdminMailer.monthly_subscription_payment_retry_failed(user.id).deliver_later

        invoice.update_attributes(next_payment_at: invoice.next_payment_at + RETRY_PAYMENT_DELAY)
      end

      def authorize_user_card_access
        user.update_attributes(card_access: :authorized)
        ResamaniaApi::PushUserWorker.perform_async(user.id)
      end

      def forbid_user_card_access
        unless user.card_access.forced_authorized?
          user.update_attributes(card_access: :forbidden)
          ResamaniaApi::PushUserWorker.perform_async(user.id)
        end
      end
    end
  end
end
