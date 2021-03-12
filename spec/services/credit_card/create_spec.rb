require 'rails_helper'

describe CreditCard::Create do
  let!(:user) { FactoryBot.create(:user, :with_registered_credit_card, paybox_user_reference: 'TEMPLE_TEST_USER') }
  let!(:subscription) { FactoryBot.create(:subscription, user: user, state: 'running') }
  let!(:subscription2) { FactoryBot.create(:subscription, user: user, state: 'pending') }
  let!(:activemerchant_credit_card) { FactoryBot.build(:activemerchant_credit_card, :valid) }

  before do
    user.current_credit_card.update_attributes(paybox_reference: 'foo_bar')
  end

  subject { CreditCard::Create.new(user, activemerchant_credit_card) }

  describe '#user' do
    describe '#user' do
      it { expect(subject.user).to eql user }
    end
  end

  describe '#activemerchant_credit_card' do
    describe '#activemerchant_credit_card' do
      it { expect(subject.activemerchant_credit_card).to eql activemerchant_credit_card }
    end
  end

  describe '#credit_card' do
    describe '#credit_card' do
      it { expect(subject.credit_card).to be_nil }
    end
  end

  describe '#execute' do
    context 'when update is successful' do
      it 'saves credit_card and user' do
        VCR.use_cassette 'user credit card update success' do
          user_credit_cards_count = user.credit_cards.size
          old_paybox_reference = user.current_credit_card.paybox_reference

          user.should_receive(:credit_cards) { [activemerchant_credit_card] }.at_least(:once)

          expect(subject.execute).to be true

          expect(subject.credit_card.user).to eql user
          expect(subject.credit_card.paybox_reference).not_to eql old_paybox_reference
          expect(subject.credit_card).to be_persisted

          expect(user.reload.credit_cards.size).to eql user_credit_cards_count + 1
          expect(user.current_credit_card).to eql subject.credit_card
          expect(user).to be_persisted
        end
      end
    end
    context 'when update fails' do
      it 'should return false' do
        VCR.use_cassette 'user credit card update failure' do
          user.credit_cards << FactoryBot.create(:credit_card)
          subject.should_receive(:update_credit_card_reference).and_return(false)

          expect(subject.execute).to be false
        end
      end
    end

    context 'when update has failed' do
      let(:activemerchant_credit_card) { FactoryBot.build(:activemerchant_credit_card, number: '111222') }

      it 'does not save the credit_card' do
        VCR.use_cassette 'user credit card update failure' do
          user_credit_cards_count = user.credit_cards.size

          expect(subject.execute).to be false

          expect(subject.credit_card).not_to be_persisted

          expect(user.reload.credit_cards.size).to eql user_credit_cards_count
          expect(user.credit_cards).not_to include(subject.credit_card)
          expect(user.current_credit_card).not_to eql subject.credit_card
        end
      end
    end

    context 'when user has no payment mean yet' do
      it 'creates credit_card and user' do
        VCR.use_cassette 'user credit card creation' do
          user_credit_cards_count = user.credit_cards.size
          old_paybox_reference = user.current_credit_card.paybox_reference

          expect(subject.execute).to be true

          expect(subject.credit_card.user).to eql user
          expect(subject.credit_card.paybox_reference).not_to eql old_paybox_reference
          expect(subject.credit_card).to be_persisted

          expect(user.reload.credit_cards.size).to eql user_credit_cards_count + 1
          expect(user.credit_cards).to include(subject.credit_card)
          expect(user.current_credit_card).to eql subject.credit_card
          expect(user).to be_persisted
        end
      end
    end
  end

  describe '#create_paybox_profile', vcr: { cassette_name: 'paybox_create_profile' } do
    before do
      subscription.state = 'pending'
      subscription.save!
      subscription.reload
    end
    it 'calls PayboxAPI and updates the CB' do
      paybox_answer = double
      ActiveMerchant::Billing::PayboxDirectPlusGateway.any_instance.should_receive(:create_payment_profile) { paybox_answer }
      paybox_answer.should_receive(:success?) { true }
      paybox_answer.should_receive(:params) { { credit_card_reference: 'plop' } }
      cb = CreditCard.new
      subject.should_receive(:credit_card).at_least(:once) { cb }
      cb.should_receive(:save!)
      cb.should_receive(:update_attributes!)
      user.should_receive(:save!).at_least(:once)
      subject.should_receive(:pay_and_start_subscription)
      subject.send(:create_paybox_profile)
    end
  end

  describe '#pay_and_start_subscription' do
    before do
      subscription.state = 'pending'
      subscription.save!
      subscription.reload
    end
    it 'make the first payment and prepare the next one' do
      deffered = double('Invoice::Deferred::Create.new')
      subject.should_receive(:make_first_payment).and_return(true)
      subject.should_receive(:set_paybox_user_reference)
      Invoice::Deferred::Create.should_receive(:new) { deffered }
      deffered.should_receive(:execute)
      subject.send(:pay_and_start_subscription)
    end
    it 'should return false' do
      subject.should_receive(:make_first_payment).and_return(false)
      expect(subject.send(:pay_and_start_subscription)).to eql(false)
    end
  end

  describe '#make_first_payment' do
    it 'creates and finish the first invoice' do
      invoice = double('Invoice.new')
      order = double('Order::CreateFromSubscription.new')
      charger = double('Invoice::Charge.new')
      Invoice.should_receive(:new) { invoice }
      invoice.should_receive(:copy_user_attributes)
      invoice.should_receive(:wait_for_payment!)
      Order::CreateFromSubscription.should_receive(:new) { order }
      order.should_receive(:execute)
      Invoice::Charge.should_receive(:new) { charger }
      charger.should_receive(:execute)
      subject.send(:make_first_payment)
    end
  end
end
