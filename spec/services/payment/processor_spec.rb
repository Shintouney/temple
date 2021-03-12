require 'rails_helper'

describe Payment::Processor do
  subject { Payment::Processor.new(payment) }

  let(:paybox_gateway) { ActiveMerchant::Billing::PayboxDirectPlusGateway }

  let!(:activemerchant_credit_card) { FactoryBot.build(:activemerchant_credit_card, :valid) }
  let!(:credit_card) { CreditCard.build_with_activemerchant_credit_card(activemerchant_credit_card) }

  let(:user) { FactoryBot.create(:user) }
  let(:invoice) { Invoice.create(start_at: Date.today, end_at: Date.today, user: user, total_price_ati: 134.87).tap(&:copy_user_attributes) }
  let(:orders) { FactoryBot.create_list(:order, 10, invoice: invoice, user: user, state: 'processing_payment') }
  let(:payment) { FactoryBot.create(:payment, user: user, invoices: [invoice], credit_card: credit_card) }

  let(:response_double) { double }

  before do
    credit_card.user = user
    user.current_credit_card = credit_card
    allow(response_double).to receive(:params) {
      { 'paybox_transaction' => '1234', 'comment' => 'plop', 'credit_card_reference' => 'SLDLrcsLMPC' }
    }
    user.payment_mode = 'cb'
    user.save!
    credit_card.save!
  end

  describe '#new' do
    context 'with payment not pending' do
      before do
        payment.credit_card = user.current_credit_card
        payment.accept!
      end

      it 'raises an ArgumentError' do
        expect { Payment::Processor.new(payment) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#execute' do
    context 'with a new user' do
      before { payment.credit_card = user.current_credit_card }

      context 'when profile creation succeeds' do
        let(:response_params) { {'authorization' => 'auth_token123', 'credit_card_reference' => 'cc_ref123'} }

        before do
          paybox_gateway.any_instance.should_receive(:create_payment_profile).
                         once.
                         with(
                          100,
                          payment.credit_card.to_activemerchant,
                          user_reference: user.paybox_user_reference
                         ).
                         and_return(response_double)
          response_double.should_receive(:success?).once.and_return(true)
          response_double.should_receive(:params).with(no_args).at_least(:once).and_return(response_params)
        end

        context 'when capture succeeds' do
          before do
            paybox_gateway.any_instance.should_receive(:purchase).
                           once.
                           with(
                              (134.87 * 100).to_i,
                              payment.credit_card.to_activemerchant,
                              user_reference: user.paybox_user_reference,
                              order_id: payment.id,
                              credit_card_reference: 'cc_ref123'
                             ).
                           and_return(response_double)
            response_double.should_receive(:success?).once.and_return(true)
          end

          it 'updates payment and user paybox fields' do
            expect(payment.price).to eql 0.0
            expect(payment.paybox_transaction).to be_nil
            expect(user.current_credit_card.paybox_reference).to be_nil

            subject.execute

            expect(payment.price).to eql 134.87
            expect(payment.paybox_transaction).to eql 'auth_token123'
            expect(user.reload.current_credit_card.paybox_reference).to eql 'cc_ref123'
          end
        end

        context 'when capture fails' do
          before do
            paybox_gateway.any_instance.should_receive(:purchase).
                           once.
                           with(
                              (134.87 * 100).to_i,
                              payment.credit_card.to_activemerchant,
                              user_reference: user.paybox_user_reference,
                              order_id: payment.id,
                              credit_card_reference: 'cc_ref123'
                             ).
                           and_return(response_double)
            response_double.should_receive(:success?).once.and_return(false)
          end

          it 'updates payment and user paybox fields' do
            expect(payment.price).to eql 0.0
            expect(payment.paybox_transaction).to be_nil
            expect(user.current_credit_card.paybox_reference).to be_nil

            subject.execute

            expect(payment.price).to eql 134.87
            expect(payment.paybox_transaction).to eql 'auth_token123'
            expect(user.reload.current_credit_card.paybox_reference).to eql 'cc_ref123'
          end
        end
      end

      context 'when profile creation fails' do
        before do
          paybox_gateway.any_instance.should_receive(:create_payment_profile).
                         once.
                         with(
                          100,
                          payment.credit_card.to_activemerchant,
                          user_reference: user.paybox_user_reference
                         ).
                         and_return(response_double)
          response_double.should_receive(:success?).once.and_return(false)
        end

        it 'does not update payment' do
          expect(payment.price).to eql 0.0
          expect(payment.paybox_transaction).to be_nil
          expect(user.current_credit_card.paybox_reference).to be_nil

          expect(subject.execute).to be false

          expect(payment.price).to eql 134.87
          expect(payment.paybox_transaction).to be_nil
          expect(user.current_credit_card.paybox_reference).not_to be_nil
        end
      end
    end

    context 'with an existing user' do
      before do
        credit_card.paybox_reference = 'SLDLrcsLMPC'
        credit_card.save!

        payment.credit_card = user.current_credit_card
      end

      context 'when purchase succeeds' do
        let(:response_params) { {'authorization' => 'auth_token123', 'credit_card_reference' => 'cc_ref123'} }

        before do
          paybox_gateway.any_instance.should_receive(:purchase).
                         once.
                         with(
                          (134.87 * 100).to_i,
                          payment.credit_card.to_activemerchant,
                          user_reference: user.paybox_user_reference,
                          order_id: payment.id,
                          credit_card_reference: 'SLDLrcsLMPC'
                         ).
                         and_return(response_double)
          response_double.should_receive(:success?).once.and_return(true)
          response_double.should_receive(:params).with(no_args).at_least(:once).and_return(response_params)
        end

        it 'updates payment and user paybox fields' do
          expect(payment.price).to eql 0.0
          expect(payment.paybox_transaction).to be_nil
          expect(user.current_credit_card.paybox_reference).to eql('SLDLrcsLMPC')

          expect(subject.execute).to be true

          expect(payment.price).to eql 134.87
          expect(payment.paybox_transaction).to eql('auth_token123')
          expect(user.reload.current_credit_card.paybox_reference).to eql('cc_ref123')
        end
      end

      context 'when user has a valid SEPA mandate', vcr: { cassette_name: 'processor_mandate'} do
        let!(:mandate) { FactoryBot.create :mandate, user: user }
        let(:slimpay) { double('Slimpay::DirectDebit') }
        let(:response) { { 'executionStatus' => 'toprocess', 'id' => '123456' } }

        before do
          user.payment_mode = 'sepa'
        end

        it 'updates payment and invoice' do
          Slimpay::DirectDebit.should_receive(:new) { slimpay }
          slimpay.should_receive(:make_payment) { response }
          JSON.should_receive(:parse) { response }
          expect(payment.price).to eql 0.0
          expect(payment.paybox_transaction).to be_nil
          expect(payment.user.mandates.ready.last).not_to be_nil
          expect(subject.execute).to be true
          expect(payment.price).to eql 134.87
          expect(payment.state).to eql('waiting_slimpay_confirmation')
        end
      end

      context 'when purchase fails' do
        before do
          paybox_gateway.any_instance.should_receive(:purchase).
                         once.
                         with(
                          (134.87 * 100).to_i,
                          payment.credit_card.to_activemerchant,
                          user_reference: user.paybox_user_reference,
                          order_id: payment.id,
                          credit_card_reference: 'SLDLrcsLMPC'
                         ).
                         and_return(response_double)
          response_double.should_receive(:success?).once.and_return(false)
        end

        it 'does not update payment' do
          expect(payment.price).to eql 0.0
          expect(payment.paybox_transaction).to be_nil
          expect(user.current_credit_card.paybox_reference).to eql('SLDLrcsLMPC')

          expect(subject.execute).to be false

          expect(payment.price).to eql 134.87
          expect(payment.paybox_transaction).to be_nil
          expect(user.current_credit_card.paybox_reference).to eql('SLDLrcsLMPC')
        end
      end
    end
  end

  describe '#process_slimpay_payment', vcr: { cassette_name: 'processor_process_slimpay_payment'} do
    let!(:mandate) { FactoryBot.create :mandate, user: user }

    before do
      user.payment_mode = 'sepa'
    end

    it 'calls Slimpay HAPI and updates the payment' do
      slimpay_answer = { 'executionStatus' => Payment::WAITING_TO_PROCESS, 'id' => '987654321' }
      slimpay_dd = double('Slimpay::DirectDebit')
      Slimpay::DirectDebit.should_receive(:new) { slimpay_dd }
      slimpay_dd.should_receive(:make_payment) { slimpay_answer }
      JSON.should_receive(:parse) { slimpay_answer }
      subject.execute
      expect(payment.slimpay_direct_debit_id).not_to be_nil
      expect(payment.slimpay_status).to eql(Payment::WAITING_TO_PROCESS)
    end
  end
end
