require 'rails_helper'

describe OrderItemDecorator do
  subject do
    OrderItemDecorator.decorate(FactoryBot.build(:order_item,
                                                    product_price_ati: 42.42,
                                                    product_price_te: 24.24,
                                                    product_taxes_rate: 20))
  end

  describe '#product_price_ati' do
    describe '#product_price_ati' do
      it { expect(subject.product_price_ati).to match('42,42') }
    end
  end

  describe '#product_price_te' do
    describe '#product_price_te' do
      it { expect(subject.product_price_te).to match('24,24') }
    end
  end

  describe '#product_taxes_rate' do
    describe '#product_taxes_rate' do
      it { expect(subject.product_taxes_rate).to match('20,00') }
    end
  end
end
