class Invoice
  module Deferred
    class Close

      attr_reader :invoice, :subscription, :user

      def initialize(invoice)
        @invoice = invoice
        raise ArgumentError.new("invoice cannot be nil") unless @invoice.present?
        
        @user = invoice.user
        raise ArgumentError.new("invoice ##{invoice.id} is not related to a user") unless @user.present?
        raise ArgumentError.new("invoice ##{invoice.id} is not open to be closed") unless @invoice.open?

        @subscription = user.current_subscription
      end

      def execute
        Invoice.transaction do
          if subscription.present? and subscription.running?
            create_order_from_subscription
          else
            forbid_user_card_access
          end

          user.update!(current_deferred_invoice_id: nil)

          invoice.wait_for_payment!

          invoice.skip_payment! if invoice.total_price_ati == 0.0
        end

        invoice.pending_payment? || invoice.payment_not_needed?
      end

      private

      def create_order_from_subscription
        unless Order::CreateFromSubscription.new(invoice, subscription).execute
          raise ActiveRecord::Rollback
        end
      end

      def forbid_user_card_access
        user.update_attributes!(card_access: 'forbidden')
        ResamaniaApi::PushUserWorker.perform_async(user.id)
      end
    end
  end
end
