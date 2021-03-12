require 'rails_helper'

describe Order do
  it_behaves_like "a model with total prices"

  it { is_expected.to have_many(:order_items) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:invoice) }

  describe '#destroy' do
    subject { FactoryBot.create(:order) }

    context 'with an invoice waiting for payment' do
      before do
        subject.invoice.wait_for_payment!
      end

      it 'does not destroy the record' do
        expect(subject.destroy).to be false

        expect(Order.exists?(subject.id)).to be true
      end
    end

    context 'with an open invoice' do
      it 'destroys the record' do
        expect(subject.destroy).to be_truthy

        expect(Order.exists?(subject.id)).to be false
      end
    end
  end
end
