class AddProductCategoryNameToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :product_category_name, :string

    OrderItem.reset_column_information

    OrderItem.where(product_type: 'Article').each do |order_item|
      if order_item.product.present? && order_item.product.article_category.present?
        order_item.update_attribute :product_category_name, order_item.product.article_category.name
      else
        order_item.update_attribute :product_category_name, 'unknown'
      end
    end
  end
end
