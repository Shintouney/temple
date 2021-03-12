module CSVExporter
  class OrderItems < Base
    COLUMNS = {
      created_at: ::OrderItem.human_attribute_name(:created_at),
      product_name: ::OrderItem.human_attribute_name(:product_name),
      article_category: Article.human_attribute_name(:article_category),
      product_price_ati: ::OrderItem.human_attribute_name(:product_price_ati),
      user_firstname: User.human_attribute_name(:firstname),
      user_lastname: User.human_attribute_name(:lastname),
      location: Order.human_attribute_name(:location)
    }

    private

    def rows(csv)
      csv.rows elements_to_csv do |csv_row, order_item|
        csv_row.cells :product_name, :created_at, :product_price_ati

        if order_item.product_type == 'Article'
          csv_row.cell :article_category, order_item.product_category_name
        end

        csv_row.cell :user_firstname, order_item.order.user&.firstname
        csv_row.cell :user_lastname, order_item.order.user&.lastname
        csv_row.cell :location, order_item.order&.location
      end
    end
  end
end
