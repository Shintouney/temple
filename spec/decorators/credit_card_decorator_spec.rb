require 'rails_helper'

describe CreditCardDecorator do
  subject { FactoryBot.build(:credit_card, expiration_month: 3, expiration_year: 2016, firstname: 'Water', lastname: 'Dancer').decorate }

  describe '#owner_name' do
    specify { expect(subject.owner_name).to eql "Water Dancer" }
  end

  describe '#expiration_date' do
    specify { expect(subject.expiration_date).to eql "03 / 2016" }
  end
end
