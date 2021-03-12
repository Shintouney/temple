require 'rails_helper'

describe OrderItem do
  it { is_expected.to belong_to(:order) }
  it { is_expected.to validate_presence_of(:order) }

  it { is_expected.to belong_to(:product) }
  it { is_expected.to validate_presence_of(:product) }

  it { is_expected.to validate_presence_of(:product_name) }

  it { is_expected.to validate_presence_of(:product_price_ati) }
  it { is_expected.to allow_value(0, 1, 2.5).for(:product_price_ati) }
  it { is_expected.not_to allow_value(-1).for(:product_price_ati) }

  it { is_expected.to validate_presence_of(:product_price_te) }
  it { is_expected.to allow_value(0, 1, 2.5).for(:product_price_te) }
  it { is_expected.not_to allow_value(-1).for(:product_price_te) }

  it { is_expected.to validate_presence_of(:product_taxes_rate) }
  it { is_expected.to allow_value(0, 1, 2.5).for(:product_taxes_rate) }
  it { is_expected.not_to allow_value(-1).for(:product_taxes_rate) }

  describe '#init_product_category_name' do
    let(:article_category) { FactoryBot.create(:article_category) }
    let(:article) { FactoryBot.create(:article, article_category: article_category) }
    let(:order_item) { FactoryBot.create(:order_item, :validated, product: article) }

    context 'the product_category_name eql to the category name of the article' do
      it { expect(order_item.product_category_name).to eql(article_category.name) }
    end
  end
end
