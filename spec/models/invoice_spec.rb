require 'rails_helper'

describe Invoice do
  it_behaves_like "a model with total prices"

  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:orders) }
  it { is_expected.to have_many(:order_items) }
  it { is_expected.to have_and_belong_to_many(:payments) }

  it { is_expected.to validate_presence_of(:start_at) }
  it { is_expected.to validate_presence_of(:end_at) }

  context 'without a date field set' do
    it { is_expected.not_to validate_presence_of(:subscription_period_start_at) }
    it { is_expected.not_to validate_presence_of(:subscription_period_end_at) }
    it { is_expected.not_to validate_presence_of(:next_payment_at) }
  end

  context 'with a date field set' do
    before { subject.subscription_period_start_at = Date.today }

    it { is_expected.to validate_presence_of(:subscription_period_end_at) }
    it { is_expected.to validate_presence_of(:next_payment_at) }
  end

  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_presence_of(:user_firstname) }
  it { is_expected.to validate_presence_of(:user_lastname) }
  it { is_expected.to validate_presence_of(:user_street1) }
  it { is_expected.to validate_presence_of(:user_postal_code) }
  it { is_expected.to validate_presence_of(:user_city) }

  describe '#chargeable?' do
    subject { FactoryBot.create(:invoice, next_payment_at: next_payment_at, state: state) }

    context 'with a next_payment_at in the future' do
      let(:next_payment_at) { Date.tomorrow }
      let(:state) { 'pending_payment' }

      describe '#chargeable?' do

        it { expect(subject.chargeable?).to be false }
      end
    end

    context 'with state set to paid' do
      let(:next_payment_at) { Date.yesterday }
      let(:state) { 'paid' }

      describe '#chargeable?' do
        it { expect(subject.chargeable?).to be false }
      end
    end

    context 'with a next_payment_at in the past and paid set to false' do
      let(:next_payment_at) { Date.yesterday }
      let(:state) { 'pending_payment' }

      describe '#chargeable?' do
        it { expect(subject.chargeable?).to be true }
      end
    end

    context 'without next_payment_at' do
      subject { FactoryBot.create(:invoice, state: state, next_payment_at: nil, subscription_period_start_at: nil, subscription_period_end_at: nil) }

      context 'with state set to pending_payment' do
        let(:state) { 'pending_payment' }

        describe '#chargeable?' do
          it { expect(subject.chargeable?).to be true }
        end
      end

      context 'with state set to paid' do
        let(:state) { 'paid' }

        describe '#chargeable?' do
          it { expect(subject.chargeable?).to be false }
        end
      end
    end
  end

  describe '#copy_user_attributes' do
    subject { FactoryBot.build(:invoice) }

    let(:user) { subject.user }

    before do
      subject.copy_user_attributes
    end

    it "should copy user attributes to the payment record" do
      expect(subject.user_firstname).to eql(user.firstname)
      expect(subject.user_lastname).to eql(user.lastname)
      expect(subject.user_street1).to eql(user.street1)
      expect(subject.user_street2).to eql(user.street2)
      expect(subject.user_postal_code).to eql(user.postal_code)
      expect(subject.user_city).to eql(user.city)
    end
  end

  describe '#compute_total_price' do
    subject { FactoryBot.create(:invoice) }

    context "without any order_item" do
      it 'should set the total prices 0' do
        subject.update_attributes!(total_price_ati: 10)

        subject.compute_total_price
        subject.save!

        subject.reload
        expect(subject.total_price_ati).to eql(0)
      end
    end

    context "with order_items" do
      let!(:order) { FactoryBot.create(:order, invoice: subject, user: subject.user) }
      let!(:order_items) do
        [
          FactoryBot.create(:order_item,
                             order: order,
                             product_price_ati: 2874.88,
                             product_price_te: 2725,
                             product_taxes_rate: 5.5,
                             product_name: "Test product",
                             product: FactoryBot.create(:subscription_plan)),
          FactoryBot.create(:order_item,
                             order: order,
                             product_price_ati: 2874.88,
                             product_price_te: 2725,
                             product_taxes_rate: 5.5,
                             product_name: "Test product 2",
                             product: FactoryBot.create(:subscription_plan))
        ]
      end

      it 'should set the total prices' do
        subject.compute_total_price
        subject.save!

        subject.reload

        expect(subject.total_price_ati.to_f).to eql(5749.75)
      end
    end
  end

  describe '#computed_total_price_te' do
    subject { FactoryBot.create(:invoice) }

    context "without any order_item" do
      it 'should return 0' do
        expect(subject.computed_total_price_te).to eql(0)
      end
    end

    context "with order_items" do
      let!(:orders) { FactoryBot.create_list(:order, 2, user: subject.user, invoice: subject) }
      let(:article1) { FactoryBot.create(:article, price_te: 20) }
      let(:article2) { FactoryBot.create(:article, price_te: 22) }

      before do
        Order::AddProduct.new(orders.first, article1).execute
        Order::AddProduct.new(orders.last, article2).execute
      end

      it 'should return the sum of the order items te prices' do
        expect(subject.computed_total_price_te).to eql(42)
      end
    end
  end

  describe '#wait_for_payment!' do
    subject { FactoryBot.build(:invoice) }

    let(:product1) { FactoryBot.create(:article, price_ati: 120, price_te: 100, taxes_rate: 20).reload }
    let(:product2) { FactoryBot.create(:article, price_ati: 60, price_te: 50, taxes_rate: 20).reload }

    before do
      Invoice::AddArticles.new(subject, [product1.id, product2.id]).execute
    end

    it 'changes the invoice state' do
      expect { subject.wait_for_payment! }.to change { subject.state }.from('open').to('pending_payment')
    end

    it 'computes the total price ati' do
      expect { subject.wait_for_payment! }.to change { subject.total_price_ati }.from(0.0).to(180.0)
    end
  end

  describe '#cancel!' do
    subject { FactoryBot.build(:invoice, state: 'pending_payment') }

    it 'changes the invoice state' do
      expect { subject.cancel! }.to change { subject.state }.from('pending_payment').to('canceled')

      expect(subject.canceled_at.to_date).to eq(Date.today)
    end
  end

  describe '#refund! from paid status' do
    subject { FactoryBot.build(:invoice, state: 'paid') }

    it 'changes the invoice state' do
      expect { subject.refund! }.to change { subject.state }.from('paid').to('refunded')

      expect(subject.refunded_at.to_date).to eq(Date.today)
    end
  end
end
