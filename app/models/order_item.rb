class OrderItem < ActiveRecord::Base
  belongs_to :order
  validates :order, presence: true

  belongs_to :product, polymorphic: true
  validates :product, presence: true

  validates :product_name, presence: true

  validates :product_price_ati, presence: true
  validates :product_price_ati, numericality: { greater_than_or_equal_to: 0 }

  validates :product_price_te, presence: true
  validates :product_price_te, numericality: { greater_than_or_equal_to: 0 }

  validates :product_taxes_rate, presence: true
  validates :product_taxes_rate, numericality: { greater_than_or_equal_to: 0 }

  before_validation :init_product_category_name, on: :create

  private

  def init_product_category_name
    return if product.nil? || product_type != "Article"
    self.product_category_name = product.article_category.name
  end
end
