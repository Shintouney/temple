require 'rails_helper'

describe PaymentDecorator do
  subject { FactoryBot.create(:payment, :with_credit_card).decorate }

  describe '#created_at' do
    specify { expect(subject.created_at).to eql I18n.l(Date.today) }
  end
end
