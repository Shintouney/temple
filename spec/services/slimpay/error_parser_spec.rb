require 'rails_helper'

describe Slimpay::ErrorParser do
  subject { Slimpay::ErrorParser.new('spec/fixtures/slimpay_rtrans.csv') }

  let(:csv) { subject.instance_variable_get(:@csv) }
  let(:array) { csv.send(:readlines) }
  let!(:user) { FactoryBot.create :user, :with_mandate }
  let!(:payment) { FactoryBot.create :payment, user_id: user.id, id: 8518, price: 125.0, state: 'waiting_slimpay_confirmation' }
  let!(:invoice) { FactoryBot.create :invoice, user_id: user.id, state: 'sepa_waiting' }
  let(:csv_row) do
    ['5', nil, 8518, nil, nil, nil, nil, nil, nil, nil,
      nil, nil, nil, nil, nil, "payment test product", nil, 'REJ', nil, 'AM04',
      'Insufficient funds', nil, nil, nil
    ]
  end

  before do
    invoice.payments << payment
    invoice.save!
  end

  describe '#execute' do
    it 'reads the CSV file' do
      csv = double('CSV')
      CSV.should_receive(:open) { csv }
      csv.should_receive(:readlines) { [['0', ""], ['14', ""], ['9', nil]] }
      Slimpay::ErrorParser.any_instance.should_receive(:process_errors)
      subject.execute
    end
    context 'bad csv' do
      subject { Slimpay::ErrorParser.new('spec/fixtures/bad_slimpay_rtrans.csv') }
      it 'logs errors' do
        subject.should_receive(:log_error)
        Slimpay::MandateImport.any_instance.should_not_receive(:process_mandates)
        subject.execute
      end
      context 'no csv footer' do
        it 'logs errors' do
          csv = double('CSV')
          CSV.should_receive(:open) { csv }
          csv.should_receive(:readlines) { [['0', ""], ['5', ""]] }
          subject.should_receive(:log_error)
          Slimpay::MandateImport.any_instance.should_not_receive(:process_mandates)
          subject.execute
        end
      end
    end
  end

  describe '#process_errors' do
    before do
      subject.instance_variable_set(:@csv_array, array)
    end

    it 'update payments and invoices' do
      subject.should_receive(:process_payment).at_least(:twice) { payment }
      subject.should_receive(:log_transaction).at_least(:twice)
      subject.should_not_receive(:log_error)
      subject.send(:process_errors)
    end
  end

  describe '#process_payment' do
    subject {Slimpay::ErrorParser.new('spec/fixtures/slimpay_REJ.csv')}

    let(:payment_declined) { FactoryBot.create :payment, user_id: user.id, price: 125.0, state: 'declined' }

    before(:each) do
      invoice.update_attribute(:state, 'sepa_waiting')
      payment.update_attribute(:state, 'waiting_slimpay_confirmation')
    end

    it 'Invoice should be in pending_payment' do
      payment.update_attribute(:state, 'waiting_slimpay_confirmation')
      invoice.payments << payment_declined
      invoice.save!

      expect(invoice.state).to eql('sepa_waiting')
      expect(payment.state).to eql('waiting_slimpay_confirmation')

      subject.execute
      invoice.reload
      payment.reload
      expect(invoice.state).to eql('pending_payment')
      expect(payment.state).to eql('declined')
    end

    it 'Invoice should be in pending_payment_retry' do
      payment.update_attribute(:state, 'waiting_slimpay_confirmation')
      invoice.payments.with_state('declined').destroy_all

      expect(invoice.state).to eql('sepa_waiting')
      expect(payment.state).to eql('waiting_slimpay_confirmation')

      subject.execute
      invoice.reload
      payment.reload
      expect(invoice.state).to eql('pending_payment_retry')
      expect(payment.state).to eql('declined')
    end
  end

  describe 'log_error' do
    let!(:file) { File.new('./test_log.log', 'a+') }
    after do
      File.delete('./test_log.log')
    end
    it 'write the error in a log file' do
      File.should_receive(:open).at_least(:once) { file }
      file.should_receive(:write)
      file.should_receive(:close)
      exception = double("exception")
      exception.should_receive(:message)
      subject.send(:log_error, csv_row, 1, exception)
    end

    it 'write the r-transactions in a log file' do
      File.should_receive(:open).at_least(:once) { file }
      file.should_receive(:write)
      file.should_receive(:close)
      subject.send(:log_transaction, csv_row, 2)
    end
  end
end
