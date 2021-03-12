class Invoice
  class AddArticles

    attr_reader :user, :order, :invoice, :article_ids, :location

    def initialize(invoice, article_ids, location = nil)
      @invoice = invoice
      raise ArgumentError.new("invoice cannot be nil") unless @invoice.present?

      @user = @invoice.user
      raise ArgumentError.new("invoice ##{@invoice.try(:id)} is not related to a user") unless @user.present?
      raise ArgumentError.new("invoice ##{@invoice.try(:id)} is not open") unless @invoice.open?

      @article_ids = article_ids
      @location = location
    end

    def execute
      result = false

      Invoice.transaction do
        create_order

        result = order.persisted? && order.order_items.size == article_ids.size

        raise ActiveRecord::Rollback unless result
      end

      result
    end

    private

    def create_order
      @order = Order.new(user: user, invoice: invoice, location: location)

      article_ids.each do |article_id|
        Order::AddProduct.new(order, Article.find(article_id)).execute
      end

      order.save
    end
  end
end
