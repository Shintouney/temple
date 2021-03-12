require 'rails_helper'

describe CreditCard do

  it { is_expected.to belong_to(:user) }

  it { is_expected.to validate_presence_of(:user) }

  it { is_expected.to allow_value(1, 6, 12).for(:expiration_month) }
  it { is_expected.not_to allow_value(-1, 0, 13).for(:expiration_month) }

  describe '.build_with_activemerchant_credit_card' do
    subject { CreditCard.build_with_activemerchant_credit_card(activemerchant_credit_card, additional_params) }
    let(:activemerchant_credit_card) do
      FactoryBot.build(:activemerchant_credit_card,
                        number: '8364411402812938',
                        first_name: 'Syrio',
                        last_name: 'Forel',
                        month: 9,
                        year: 2008,
                        verification_value: '921',
                        brand: 'master')
    end
    let(:additional_params) { {} }

    it 'sets fields properly' do
      expect(subject.number).to eql 'xxxxxxxxxxxx2938'
      expect(subject.firstname).to eql 'Syrio'
      expect(subject.lastname).to eql 'Forel'
      expect(subject.expiration_month).to eql 9
      expect(subject.expiration_year).to eql 2008
      expect(subject.cvv).to eql '921'
      expect(subject.brand).to eql 'master'
      expect(subject.to_activemerchant).to eql activemerchant_credit_card
    end

    context 'with additional params' do
      let(:user) { FactoryBot.create(:user) }
      let(:additional_params) { {user: user} }

      it 'sets additional params properly' do
        expect(subject.user).to eql user
      end
    end
  end

  describe "#number=" do
    before { subject.number = '7653126351726351' }
    it { expect(subject.number).to eql 'xxxxxxxxxxxx6351'}
  end

  describe "#cvv=" do
    before { subject.cvv = '524' }
    it { expect(subject.cvv).to eql '524'}
    it { expect(subject.read_attribute(:cvv)).not_to eql '524'}
  end

  describe "#brand=" do
    before { subject.brand = 'master' }
    it { expect(subject.brand).to eql 'master'}
    it { expect(subject.read_attribute(:brand)).not_to eql 'master'}
  end

  describe "#safe_write_attribute" do
    before { subject.brand = nil }
    before { subject.cvv = nil }
    before { subject.number = nil }

    it { expect(subject.errors.count).to eql(3) }
  end

  describe '#to_activemerchant' do
    context 'with no fields set' do
      it 'returns an empty ActiveMerchant credit card' do
        expect(subject.to_activemerchant.number).to be_nil
        expect(subject.to_activemerchant.first_name).to be_nil
        expect(subject.to_activemerchant.last_name).to be_nil
        expect(subject.to_activemerchant.month).to be_nil
        expect(subject.to_activemerchant.year).to be_nil
        expect(subject.to_activemerchant.verification_value).to be_nil
        expect(subject.to_activemerchant.brand).to be_nil
      end
    end

    context 'with fields set' do
      before do
        subject.number = '2406390282155263'
        subject.firstname = 'Jane'
        subject.lastname = 'Doh'
        subject.expiration_month = 7
        subject.expiration_year = 2019
        subject.cvv = '214'
        subject.brand = 'master'
      end

      it 'returns an ActiveMerchant' do
        expect(subject.to_activemerchant.number).to eql 'xxxxxxxxxxxx5263'
        expect(subject.to_activemerchant.first_name).to eql 'Jane'
        expect(subject.to_activemerchant.last_name).to eql 'Doh'
        expect(subject.to_activemerchant.month).to eql 7
        expect(subject.to_activemerchant.year).to eql 2019
        expect(subject.to_activemerchant.verification_value).to eql '214'
        expect(subject.to_activemerchant.brand).to eql 'master'
      end
    end
  end
end
