class Order
  class AddProduct
    attr_reader :order, :product, :product_price_ati, :product_price_te

    def initialize(order, product, product_price_ati = nil, product_price_te = nil)
      @order = order
      @product = product

      if product_price_ati.present?
        raise ArgumentError.new("product_price_ati cannot be set without product_price_te") unless product_price_te.present?

        @product_price_ati = product_price_ati
        @product_price_te = product_price_te
      else
        @product_price_ati = product.price_ati
        @product_price_te = product.price_te
      end
    end

    # Public: Processes the addition of the product to the order.
    #
    # Returns a Boolean, true if successful, false otherwise.
    def execute
      order_item = OrderItem.new(product: product, order: order)

      order.transaction do
        set_order_item_attributes(order_item)
        order.save!
        order_item.save!
      end

      order.reload
      order_item.reload.persisted?
    end

    private

    def set_order_item_attributes(order_item)
      order_item.product_name = product.name
      order_item.product_taxes_rate = product.taxes_rate

      order_item.product_price_ati = product_price_ati
      order_item.product_price_te = product_price_te
    end
  end
end
