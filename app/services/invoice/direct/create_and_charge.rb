class Invoice
  module Direct
    class CreateAndCharge
      attr_reader :user, :article_ids, :invoice, :location

      def initialize(user, article_ids, location = nil)
        @user = user
        @article_ids = article_ids
        @location = location
      end

      def execute
        result = false

        Invoice.transaction do
          result = create_invoice && Invoice::Charge.new(invoice).execute

          raise ActiveRecord::Rollback unless result
        end

        result
      end

      private

      def create_invoice
        @invoice = Invoice.new(start_at: Date.today, end_at: Date.today, user: user)
        invoice.copy_user_attributes

        return false unless Invoice::AddArticles.new(invoice, article_ids, location).execute

        invoice.wait_for_payment!
      end
    end
  end
end
