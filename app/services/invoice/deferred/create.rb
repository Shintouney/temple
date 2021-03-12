class Invoice
  module Deferred
    class Create
      attr_reader :subscription, :user, :invoice

      def initialize(user)
        @user = user
        raise ArgumentError.new("user cannot be nil") unless @user.present?

        @subscription = user.current_subscription
        raise ArgumentError.new("user ##{@user.id} doesn't have a current_subscription") if @subscription.nil?
        raise ArgumentError.new("user ##{@user.id} current_subscription ##{@subscription.id} is not actually running") unless @subscription.running?
      end

      def execute
        result = false

        Invoice.transaction do
          result = create_invoice && update_user_deferred_invoice
          raise ActiveRecord::Rollback unless result
        end

        result
      end

      private

      def create_invoice
        @invoice = Invoice.new(
          start_at: subscription.current_period_start_date,
          end_at: subscription.current_period_end_date,
          subscription_period_start_at: subscription.current_period_start_date + Subscription::PERIODICITY,
          subscription_period_end_at: subscription.current_period_end_date + Subscription::PERIODICITY,
          next_payment_at: subscription.current_period_end_date + 1.day,
          user: user
        )

        invoice.copy_user_attributes
        invoice.save!
      end

      def update_user_deferred_invoice
        user.current_deferred_invoice = invoice
        user.save!
      end
    end
  end
end
