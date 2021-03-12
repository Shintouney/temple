class Invoice
  module Deferred
    module Replace

      # Public: Replaces the due Invoices that are open with a new deferred Invoice.
      #
      # Returns nothing.
      def self.execute
        close_invoices
        create_invoices
      end

      private

      # Internal: Closes all the open and due deferred Invoices.
      #
      # Returns nothing.
      def self.close_invoices
        Invoice.with_state(:open).includes(:user).due.each do |invoice|
          Invoice::Deferred::Close.new(invoice).execute
        end
      end

      # Internal: Creates a new deferred Invoice for all running subscription
      #           with users without a current deferred Invoice.
      #
      # Returns nothing.
      def self.create_invoices
        Subscription.with_state(:running).includes(user: :current_deferred_invoice).each do |subscription|
          unless subscription.user.current_deferred_invoice.present?
            Invoice::Deferred::Create.new(subscription.user).execute
          end
        end
      end
    end
  end
end
