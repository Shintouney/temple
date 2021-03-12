require 'rails_helper'

describe Slimpay::MandateImport do
  subject { Slimpay::MandateImport.new('spec/fixtures/slimpay_import.csv') }

  let(:user) { FactoryBot.create :user, :with_mandate }
  let(:csv) { subject.instance_variable_get(:@csv) }
  let(:array) { csv.send(:readlines) }
  let(:csv_row) do
    ['8', nil, nil, nil, 'John Doe', nil, nil, nil, nil, nil,
      nil, nil, nil, nil, nil, nil, nil, nil, nil, 'SLMP00123',
      nil, nil
    ]
  end

  describe '#execute' do
    it 'reads the CSV file' do
      csv = double('CSV')
      CSV.should_receive(:open) { csv }
      csv.should_receive(:readlines) { [['0', ""], ['8', ""], ['9', nil]] }
      Slimpay::MandateImport.any_instance.should_receive(:process_mandates)
      subject.should_not_receive(:log_error)
      subject.execute
    end
    context 'bad csv' do
      subject { Slimpay::MandateImport.new('spec/fixtures/bad_slimpay_import.csv') }
      it 'logs errors' do
        subject.should_receive(:log_error)
        Slimpay::MandateImport.any_instance.should_not_receive(:process_mandates)
        subject.execute
      end
      context 'no csv footer' do
        it 'logs errors' do
          csv = double('CSV')
          CSV.should_receive(:open) { csv }
          csv.should_receive(:readlines) { [['0', ""], ['8', ""]] }
          subject.should_receive(:log_error)
          Slimpay::MandateImport.any_instance.should_not_receive(:process_mandates)
          subject.execute
        end
      end
    end
  end

  describe 'process_mandates' do
    before do
      subject.instance_variable_set(:@csv_array, array)
    end
    it 'loops rows to find user and create mandates' do
      subject.should_receive(:find_user).at_least(:twice) { user }
      subject.should_receive(:create_mandate).at_least(:twice)
      subject.send(:process_mandates)
    end
    it 'logs an error if no user found' do
      subject.should_receive(:find_user).at_least(:twice) { nil }
      subject.should_not_receive(:create_mandate)
      subject.send(:process_mandates)
    end
  end

  describe '#create_mandate' do
    before do
      subject.instance_variable_set(:@user, user)
    end
    specify do
      expect do
        subject.send(:create_mandate, csv_row)
      end.to change(Mandate, :count).by(1)
    end
  end

  describe '#find_user' do
    specify do
      subject.send(:find_user, csv_row)
    end
    context 'when refrence is given' do
      before do
        csv_row[::Slimpay::MandateImport::REFERENCE] = '1234'
      end
      it 'finds the user by reference' do
        User.should_receive(:find_by).once
        User.should_not_receive(:where)
        subject.send(:find_user, csv_row)
      end
    end
    context 'when email is given' do
      before do
        csv_row[::Slimpay::MandateImport::EMAIL] = 'test@test.com'
      end
      it 'finds the user by email' do
        User.should_receive(:find_by).once
        User.should_not_receive(:where)
        subject.send(:find_user, csv_row)
      end
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
      subject.send(:log_error, csv_row, 1)
    end
  end
end
