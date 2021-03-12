require 'rails_helper'

RSpec.shared_examples "a model with total prices" do
  subject { FactoryBot.create(described_class.name.downcase) }

  let(:order_items) do
    [
      FactoryBot.create(:order_item,
                         product_price_ati: 20.0028,
                         product_price_te: 18.96,
                         product_taxes_rate: 5.5,
                         product_name: "Test product",
                         product: FactoryBot.create(:article)),
      FactoryBot.create(:order_item,
                         product_price_ati: 20.0028,
                         product_price_te: 18.96,
                         product_taxes_rate: 5.5,
                         product_name: "Test product 2",
                         product: FactoryBot.create(:article)),
      FactoryBot.create(:order_item,
                         product_price_ati: 48,
                         product_price_te: 40,
                         product_taxes_rate: 20,
                         product_name: "Test product 3",
                         product: FactoryBot.create(:article))
    ]
  end

  describe '#total_prices_te_by_taxes_rates' do
    context "without any order_item" do
      it 'should return an empty hash' do
        expect(subject.total_prices_te_by_taxes_rates).to be_empty
      end
    end

    context "with order_items" do
      before do
        subject.stub(:order_items).and_return(order_items)
      end

      it 'should group and sum the order_items prices' do
        expect(subject.total_prices_te_by_taxes_rates.keys.sort).to eql([5.5, 20.0])
        expect(subject.total_prices_te_by_taxes_rates[5.5]).to eql(18.96 + 18.96)
        expect(subject.total_prices_te_by_taxes_rates[20.0]).to eql(40.0)
      end
    end
  end

  describe '#computed_total_price_te' do
    before do
      subject.stub(:order_items).and_return(order_items)
    end

    its(:computed_total_price_te) { should eql 77.92 }
  end

  describe '#computed_total_price_ati' do
    before do
      subject.stub(:order_items).and_return(order_items)
    end

    its(:computed_total_price_ati) { should eql 88.01 }
  end
end
