require 'rails_helper'

describe Order::AddProduct do
  let(:order) { FactoryBot.create(:order) }
  let(:product) { FactoryBot.create(:subscription_plan, :discounted) }

  subject { Order::AddProduct.new(order, product) }

  describe '#order' do
    describe '#order' do
      it { expect(subject.order).to eql(order) }
    end
  end

  describe '#product' do
    describe '#product' do
      it { expect(subject.product).to eql(product) }
    end
  end

  describe "product prices initializing" do
    context "without setting the product prices" do
      subject { Order::AddProduct.new(order, product) }

      describe '#product_price_ati' do
        describe '#product_price_ati' do
          it { expect(subject.product_price_ati).to eql(product.price_ati) }
        end
      end

      describe '#product_price_te' do
        describe '#product_price_te' do
          it { expect(subject.product_price_te).to eql(product.price_te) }
        end
      end
    end

    context "when setting only one product price" do
      it "should raise an error" do
        expect { Order::AddProduct.new(order, product, 100) }.to(
          raise_error(ArgumentError))
      end
    end

    context "when setting the product prices" do
      let(:init_product_price_ati) { rand(100.200) }
      let(:init_product_price_te) { rand(100.200) }

      subject { Order::AddProduct.new(order, product, init_product_price_ati, init_product_price_te) }

      describe '#product_price_ati' do
        describe '#product_price_ati' do
          it { expect(subject.product_price_ati).to eql(init_product_price_ati) }
        end
      end

      describe '#product_price_te' do
        describe '#product_price_te' do
          it { expect(subject.product_price_te).to eql(init_product_price_te) }
        end
      end
    end
  end

  describe '#execute' do
    context 'without setting the product prices' do
      it 'should add an order_item to the order with the product informations' do
        subject.execute
        order.reload

        expect(order.order_items.count).to eql(1)

        order_item = order.order_items.last
        expect(order_item.product).to eql(product)
        expect(order_item.product_name).to eql(product.name)
        expect(order_item.product_price_te).to eql(product.price_te)
        expect(order_item.product_price_ati).to eql(product.price_ati)
        expect(order_item.product_taxes_rate).to eql(product.taxes_rate)
      end
    end

    context 'setting the prices to the product discounted prices' do
      subject { Order::AddProduct.new(order, product, product.discounted_price_ati, product.discounted_price_te) }

      it 'should add an order_item to the order with the product discounted informations' do
        subject.execute
        order.reload

        expect(order.order_items.count).to eql(1)

        order_item = order.order_items.last
        expect(order_item.product).to eql(product)
        expect(order_item.product_price_te).to eql(product.discounted_price_te)
        expect(order_item.product_price_ati).to eql(product.discounted_price_ati)
        expect(order_item.product_taxes_rate).to eql(product.taxes_rate)
      end
    end

    it 'should update the order total prices' do
      total_price_ati = order.computed_total_price_ati
      total_price_te = order.computed_total_price_te

      subject.execute

      order.reload
      expect(order.computed_total_price_ati.to_d).to eql((total_price_ati + product.price_ati).to_d)
      expect(order.computed_total_price_te.to_d).to eql((total_price_te + product.price_te).to_d)
    end

    context 'with incorect data for the product' do
      before do
        product.update_attribute :price_ati, -1
      end

      it 'should return false without updating the order' do
        expect { subject.execute }.to raise_error(ActiveRecord::RecordInvalid)
        order.reload

        expect(order.order_items.count).to eql(0)
        expect(order.computed_total_price_te).to eql(0)
      end
    end
  end
end
