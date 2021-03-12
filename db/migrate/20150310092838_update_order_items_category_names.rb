class UpdateOrderItemsCategoryNames < ActiveRecord::Migration
  def up
    OrderItem.where("product_type = 'Article'").includes(product: :article_category).each do |item|
      category = item.product.article_category if item.product.present?
      item.update_attribute :product_category_name, category.name if category.present?
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
