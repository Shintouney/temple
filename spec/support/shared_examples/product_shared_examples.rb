require 'rails_helper'

RSpec.shared_examples "a product model" do
  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:price_ati) }
  it { should allow_value(0, 1, 2.5).for(:price_ati) }
  it { should_not allow_value(-1).for(:price_ati) }

  it { should validate_presence_of(:price_te) }
  it { should allow_value(0, 1, 2.5).for(:price_te) }
  it { should_not allow_value(-1).for(:price_te) }

  it { should validate_presence_of(:taxes_rate) }
  it { should allow_value(0, 1, 2.5).for(:taxes_rate) }
  it { should_not allow_value(-1).for(:taxes_rate) }

  describe 'price_te validation' do
    before { subject.price_te = 0 }

    context 'when price_ati is equal to 0' do
      before do
        subject.price_ati = 0
        subject.save
      end

      it { expect(subject.errors.messages.keys).not_to include(:price_te) }
    end

    context 'when price_ati is greater than 0' do
      before do
        subject.price_ati = 1
        subject.save
      end

      it { expect(subject.errors.messages.keys).to include(:price_te) }
    end
  end
end
