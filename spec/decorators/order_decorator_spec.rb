require 'rails_helper'

describe OrderDecorator do
  let(:order) { FactoryBot.build(:order) }
  subject { OrderDecorator.decorate(order) }

  describe '#state' do
    context 'with an open invoice' do
      describe '#state' do
        it { expect(subject.state).to eql(Invoice.human_state_name(:pending_payment)) }
      end
    end

    context 'with a pending_payment invoice' do
      before { order.invoice.wait_for_payment! }

      describe '#state' do
        it { expect(subject.state).to eql(subject.invoice.human_state_name) }
      end
    end

    context 'with a paid invoice' do
      before do
        order.invoice.wait_for_payment!
        order.invoice.accept_payment!
      end

      describe '#state' do
        it { expect(subject.state).to eql(subject.invoice.human_state_name) }
      end
    end
  end

  describe '#reference' do
    subject { OrderDecorator.decorate(FactoryBot.create(:order)) }

    describe '#reference' do
      it { expect(subject.reference).to match(subject.id.to_s) }
    end
  end

  describe '#computed_total_price_ati' do
    let!(:products) do
      [
        FactoryBot.create(:article, price_ati: 120),
        FactoryBot.create(:article, price_ati: 60),
        FactoryBot.create(:article, price_ati: 94.95)
      ]
    end

    before do
      subject.object.save!

      products.each do |product|
        Order::AddProduct.new(subject.object, product).execute
      end
    end

    describe '#computed_total_price_ati' do
      it { expect(subject.computed_total_price_ati).to match('274,96') }
    end
  end

  describe '#computed_total_price_te' do
    let!(:products) do
      [
        FactoryBot.create(:article, price_te: 273.92),
        FactoryBot.create(:article, price_te: 21.24),
        FactoryBot.create(:article, price_te: 17.89)
      ]
    end

    before do
      subject.object.save!

      products.each do |product|
        Order::AddProduct.new(subject.object, product).execute
      end
    end

    describe '#computed_total_price_te' do
      it { expect(subject.computed_total_price_te).to match('313,05') }
    end
  end

  describe '#total_taxes_amounts' do
    let!(:products) do
      [
        FactoryBot.create(:article, price_ati: 120, price_te: 100, taxes_rate: 20),
        FactoryBot.create(:article, price_ati: 60, price_te: 50, taxes_rate: 20),
        FactoryBot.create(:article, price_ati: 94.95, price_te: 90, taxes_rate: 5.5)
      ]
    end

    before do
      subject.object.save!

      products.each do |product|
        Order::AddProduct.new(subject.object, product).execute
      end
    end

    it "should sum and decorate the taxes amounts" do
      # subject.total_taxes_amounts.should eql([['20,00%', '22,40 €'], ['5,50%', '0,74 €']])
      expect(subject.total_taxes_amounts).to eql([['20,00%', '30,00 €'], ['5,50%', '4,95 €']])
    end
  end
end
