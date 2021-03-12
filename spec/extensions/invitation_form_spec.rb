require 'rails_helper'

describe InvitationForm, type: :model do
  it { is_expected.to validate_presence_of(:text) }

  it { is_expected.to validate_presence_of(:to) }
  it { is_expected.not_to allow_value('wrong, emails, adresses, friend@example.com').for(:to) }
  it { is_expected.to allow_value('friend1@example.com, friend2@example.com').for(:to) }
end
