require 'rails_helper'

RSpec.shared_examples 'a credit cardable model' do
  let!(:credit_card) do
    FactoryBot.build(:credit_card, first_name: 'John', last_name: 'Doe', number: '6385721812701293',
                      month: '06', year: '2016', brand: 'visa', verification_value: '772')
  end

  describe "#credit_card_number=" do
    before { subject.credit_card_number = '7653126351726351' }
    it { expect(subject.credit_card_number).to eql 'xxxxxxxxxxxx6351'}
  end

  describe "#credit_card_cvv" do
    before { subject.credit_card_cvv = '524' }
    it { expect(subject.credit_card_cvv).to eql '524'}
    it { expect(subject.read_attribute(:credit_card_cvv)).not_to eql '524'}
  end

  describe "#credit_card=" do
    subject { described_class.new }
    before { subject.credit_card = credit_card }

    it 'assigns credit card fields with proper values' do
      expect(subject.credit_card_number).to eql 'xxxxxxxxxxxx1293'
      expect(subject.credit_card_cvv).to eql '772'
      expect(subject.credit_card_expiration_month).to eql 6
      expect(subject.credit_card_expiration_year).to eql 2016
    end
  end

  describe "#credit_card" do
    subject { described_class.new }

    context 'with no credit card assigned' do
      it 'returns an empty ActiveMerchant credit card' do
        expect(subject.credit_card).to be_a(ActiveMerchant::Billing::CreditCard)
        expect(subject.credit_card.number).to be_nil
        expect(subject.credit_card.first_name).to be_nil
        expect(subject.credit_card.last_name).to be_nil
        expect(subject.credit_card.brand).to be_nil
        expect(subject.credit_card.verification_value).to be_nil
        expect(subject.credit_card.month).to be_nil
        expect(subject.credit_card.year).to be_nil
      end
    end

    context 'with credit card previously assigned' do
      before do
        subject.credit_card = credit_card
        subject.credit_card = nil
      end

      it 'returns an ActiveMerchant credit card with validation fields and number' do
        credit_card = subject.credit_card

        expect(credit_card.first_name).to be_nil
        expect(credit_card.last_name).to be_nil
        expect(credit_card.brand).to be_nil

        expect(credit_card.number).to eql 'xxxxxxxxxxxx1293'
        expect(credit_card.verification_value).to eql '772'
        expect(credit_card.month).to eql 6
        expect(credit_card.year).to eql 2016
      end
    end

    context 'with credit card assigned' do
      before { subject.credit_card = credit_card }
      specify { expect(subject.credit_card).to eql credit_card }
    end
  end
end
