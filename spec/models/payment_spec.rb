require 'rails_helper'

describe Payment do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:credit_card) }
  it { is_expected.to have_and_belong_to_many(:invoices) }

  it { is_expected.to validate_presence_of(:price) }

  it { is_expected.to allow_value(0, 10000).for(:price) }
  it { is_expected.not_to allow_value(-1000, -1).for(:price) }
end
