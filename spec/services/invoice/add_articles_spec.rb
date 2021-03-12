require 'rails_helper'

describe Invoice::AddArticles do
  let(:user) { FactoryBot.create(:user) }
  let(:invoice) { FactoryBot.create(:invoice, user: user) }
  let(:articles) { FactoryBot.create_list(:article, 10) }
  let(:articles_ids) { articles.map(&:id) }

  before { user.update_attributes!(current_deferred_invoice: invoice) }

  subject { Invoice::AddArticles.new(user.current_deferred_invoice, articles_ids) }

  describe '#user' do
    it { expect(subject.user).to eql user }
  end

  describe '#invoice' do
    it { expect(subject.invoice).to eql invoice}
  end

  describe '#order' do
    it { expect(subject.order).to be_nil }
  end

  describe '.new' do
    context 'when user has no current_deferred_invoice' do
      let(:invoice) { nil }
      it { expect { subject }.to raise_error { ArgumentError } }
    end

    context 'when user invoice is not open' do
      let(:invoice) { FactoryBot.create(:invoice, state: 'pending_payment') }
      it { expect { subject }.to raise_error { ArgumentError } }
    end
  end

  describe '#execute' do
    it 'returns true' do
      expect(subject.execute).to be true
    end

    it 'creates and order and adds it to the current deferred invoice' do
      expect { subject.execute }.to change { invoice.orders.count }.by(1)

      expect(subject.order.invoice).to eql subject.invoice
      expect(subject.order.user).to eql user
      expect(subject.order.order_items.count).to eql 10

      expect(subject.order).to be_persisted
    end

    context 'when execution fails' do
      let(:order_add_product_double) { double }

      before do
        Order::AddProduct.should_receive(:new).exactly(10).times.and_return(order_add_product_double)
        order_add_product_double.should_receive(:execute).exactly(10).times.and_return(false)
      end

      it 'returns false' do
        expect(subject.execute).to be false
      end

      it 'does not create an order' do
        expect { subject.execute }.not_to change { Order.count }
      end
    end
  end
end
