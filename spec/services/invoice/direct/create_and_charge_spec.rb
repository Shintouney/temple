require 'rails_helper'

describe Invoice::Direct::CreateAndCharge do
  subject { Invoice::Direct::CreateAndCharge.new(user, [product1.id, product2.id]) }

  let(:user) { FactoryBot.create(:user).tap {|user| user.current_credit_card = FactoryBot.build(:credit_card) } }
  let(:product1) { FactoryBot.create(:article, price_ati: 120, price_te: 100, taxes_rate: 20).reload }
  let(:product2) { FactoryBot.create(:article, price_ati: 60, price_te: 50, taxes_rate: 20).reload }

  describe '#user' do
    describe '#user' do
      it { expect(subject.user).to eql(user) }
    end
  end

  describe '#execute' do
    let!(:order_count) { Order.count }

    context "with a successful payment" do
      let!(:invoice_count) { Invoice.count }

      before do
        charge_invoice_double = double
        charge_invoice_double.should_receive(:execute).once.with(no_args).and_return(true)
        Invoice::Charge.should_receive(:new).with(an_instance_of(Invoice)).once.and_return(charge_invoice_double)
      end

      it "should return true" do
        expect(subject.execute).to be true
      end

      it 'should create an invoice' do
        expect { subject.execute }.to change { Invoice.count }.by(1)

        expect(subject.invoice.user).to eql user
        expect(subject.invoice.start_at).to eql Date.today
        expect(subject.invoice.end_at).to eql Date.today
        expect(subject.invoice.total_price_ati).to eql 180
      end

      it 'should create an order with the invoice' do
        expect { subject.execute }.to change { Order.count }.by(1)
        expect(Order.last.invoice).to eql subject.invoice
      end
    end

    context "with a failed payment" do
      before do
        charge_invoice_double = double
        charge_invoice_double.should_receive(:execute).once.with(no_args).and_return(false)
        Invoice::Charge.should_receive(:new).with(an_instance_of(Invoice)).once.and_return(charge_invoice_double)
      end

      it "should return false" do
        expect(subject.execute).to be false
      end

      it 'should not create an order' do
        expect { subject.execute }.not_to change { Order.count }
      end

      it 'should not create an invoice' do
        expect { subject.execute }.not_to change { Invoice.count }
      end
    end
  end
end
