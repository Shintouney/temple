require 'rails_helper'

describe Invoice::Charge do
  subject { Invoice::Charge.new(invoice) }

  let(:user) { FactoryBot.create(:user, :with_registered_credit_card, payment_mode: 'cb') }
  let(:invoice) { FactoryBot.create(:invoice, user: user, state: 'open') }
  let(:orders) { FactoryBot.create_list(:order, 3, user: user, invoice: invoice) }

  before do
    Order::AddProduct.new(orders[0], FactoryBot.create(:article, price_ati: 24, price_te: 20, taxes_rate: 20)).execute
    Order::AddProduct.new(orders[1], FactoryBot.create(:article, price_ati: 24, price_te: 20, taxes_rate: 20)).execute
    Order::AddProduct.new(orders[2], FactoryBot.create(:article, price_ati: 36, price_te: 30, taxes_rate: 20)).execute

    invoice.wait_for_payment!
  end

  describe '#new' do
    describe '#invoice' do
      it { expect(subject.invoice).to eql invoice }
    end

    describe '#user' do
      it { expect(subject.user).to eql invoice.user }
    end

    describe '#payment' do

      it { expect(subject.payment.invoices).to include(invoice) }
      it { expect(subject.payment.user).to eql user }
      it { expect(subject.payment.credit_card).to eql user.current_credit_card }
    end

    context 'with an unchargeable invoice' do
      before { invoice.accept_payment! }

      it { expect { subject }.to raise_error(ArgumentError) }
    end
  end

  describe '#execute' do
    context 'with a successful payment' do
      before { VCR.insert_cassette 'payment success' }
      after { VCR.eject_cassette 'payment success' }

      it 'creates a successful payment with its total price, and sets the invocie as paid.' do
        expect(subject.execute).to be true
        expect(subject.payment).to be_persisted
        expect(subject.payment).to be_accepted

        expect(invoice.reload.payments.first).to eql subject.payment
        expect(invoice).to be_paid
        expect(subject.payment.price).to eql 84
      end
    end

    context 'with a GHOST user' do
      let(:user) { FactoryBot.create(:user, :with_registered_credit_card, email: Settings.user.cash.email) }
      before do
        invoice.user = user
        invoice.save!
      end
      it 'bypasses classic checks' do
        subject.payment.should_receive(:compute_price)
        subject.payment.should_receive(:save!)
        subject.payment.should_receive(:accept!)
        Payment::Processor.should_not_receive(:new)

        subject.execute
      end
    end

    context 'with a failed payment' do
      before { VCR.insert_cassette 'payment failure' }
      after { VCR.eject_cassette 'payment failure' }

      it 'returns false' do
        expect(subject.execute).to be false
      end

      it 'creates a failed payment' do
        subject.execute
        expect(subject.payment).to be_persisted
        expect(subject.payment).to be_declined

        expect(invoice.reload.payments.first).to eql subject.payment
      end

      it 'does not set the invoice as paid' do
        subject.execute
        expect(invoice).not_to be_paid
      end

      it 'sets the payment total price' do
        subject.execute
        expect(subject.payment.price).to eql 84
      end
    end
  end
end
