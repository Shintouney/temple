require 'rails_helper'

describe Mandate, type: :model do
  it { is_expected.to belong_to(:user) }

  subject { Mandate.new(slimpay_order_state: Mandate::SLIMPAY_ORDER_COMPLETED, slimpay_state: Mandate::SLIMPAY_STATE_CREATED, slimpay_rum: '12345') }
  let!(:user) { FactoryBot.create :user }
  let!(:subscription) { FactoryBot.create :subscription, user: user}

  describe ".sign" do
    it "raise error in case of problem" do
      Slimpay::Order.should_receive(:new) { raise_error('test error') }
      Raven.should_receive(:capture_exception)
      Mandate.should_not_receive(:create)
      Mandate.sign(user)
    end
  end

  describe '#ready?' do
    specify { expect(subject.ready?).to be true }
  end

  describe '#waiting?' do
    before do
      subject.slimpay_order_state = Mandate::SLIMPAY_ORDER_WAITING
    end
    specify { expect(subject.waiting?).to be true }
  end

  describe '#retrieve_rum' do
    it 'calls the SLimpay API and update the Mandate accordingly' do
      order = double('Slimpay::Order.new')
      Slimpay::Order.should_receive(:new) { order }
      order.should_receive(:get_one)
      JSON.should_receive(:parse) { {'rum' => '1234', 'state' => 'closed.completed', 'dateCreated' => Time.now} }
      order.should_receive(:get_mandate)
      subject.send(:retrieve_rum)
    end
  end

  describe '#update_from_ipn' do
    let(:ipn_params) { { 'state' => 'closed.completed', 'dateCreated' => Time.now } }

    before do
      subject.user_id = user.id
      subject.save!
      subject.reload
    end

    it "updates mandate's state and eventually the rum" do
      subject.should_receive(:retrieve_rum)
      subject.should_receive(:make_first_payment) { true }
      subject.update_from_ipn(ipn_params)
    end
  end

  describe '#refresh' do
    let(:mandate) { double('Slimpay::Mandate') }
    context 'when no change happened' do
      it 'request mandates status' do
        Slimpay::Mandate.should_receive(:new) { mandate }
        mandate.should_receive(:get_one).with(subject.slimpay_rum)
        JSON.should_receive(:parse) { { 'dateRevoked' => Time.now } }
        subject.should_receive(:update_attributes)
        subject.refresh
      end
    end
    context 'when mandate has been revoked' do
      it 'updates mandate state' do
        Slimpay::Mandate.should_receive(:new) { mandate }
        mandate.should_receive(:get_one).with(subject.slimpay_rum)
        JSON.should_receive(:parse) { { 'dateRevoked' => Time.now } }
        subject.should_receive(:update_attributes)
        subject.refresh
      end
    end
  end

  describe '#refresh_from_order' do
    before do
      subject.user_id = user.id
      subject.save!
      subject.reload
    end

    it 'updates the empty mandate through its order' do
      slimpay_orders = double('Slimpay::Order.new')
      response = { 'rum' => '123456', 'state' => Mandate::SLIMPAY_ORDER_COMPLETED, 'dateCreated' => Time.zone.now }
      Slimpay::Order.should_receive(:new) { slimpay_orders }
      slimpay_orders.should_receive(:get_one) { response.to_json }
      slimpay_orders.should_receive(:get_mandate) { response.to_json }
      JSON.should_receive(:parse).at_least(:once) { response }
      allow(subject).to receive(:update_attributes)
      allow(user.subscriptions.last).to receive(:sepa_waiting?)
      allow(user.subscriptions.last).to receive(:start!)
      subject.send(:refresh_from_order)
    end
  end

  describe '#make_first_payment' do
    it 'charge an invoice for the subscription' do
      invoice = double('Invoice.new')
      order = double('Order::CreateFromSubscription.new')
      Invoice.should_receive(:new) { invoice }
      invoice.should_receive(:copy_user_attributes)
      Order::CreateFromSubscription.should_receive(:new) { order }
      order.should_receive(:execute) { true }
      invoice.should_receive(:wait_for_payment!)

      user = double
      subscriptions = double('Subscription.new')
      allow(subject).to receive(:user) { user }
      allow(user).to receive(:subscriptions) { subscriptions }
      allow(subscriptions).to receive(:pending) { [Subscription.new(state: 'pending')] }

      charger = double('Invoice::Charge.new')
      Invoice::Charge.should_receive(:new) { charger }
      charger.should_receive(:execute)

      subject.send(:make_first_payment)
    end
  end

  describe '#showable?' do
    it 'check if non-empty' do
      subject.should_receive(:ready?)
      subject.should_receive(:waiting?)
      subject.showable?
    end
  end
end
