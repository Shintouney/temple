require 'rails_helper'

describe UserCardAccess do
  subject { FactoryBot.create(:user) }

  describe 'authorize_card_access' do
    it "authorize user's card access" do
      subject.should_receive(:update_attributes).with(card_access: :authorized) { true }
      subject.authorize_card_access
    end
    it 'call material API to ban card access' do
      ResamaniaApi::PushUserWorker.should_receive(:perform_async).with(subject.id)
      subject.authorize_card_access
    end
  end

  describe 'forbid_card_access' do
    it "forbids user's card access" do
      subject.should_receive(:update_attributes).with(card_access: :forbidden) { true }
      subject.forbid_card_access
    end
    it 'call material API to ban card access' do
      ResamaniaApi::PushUserWorker.should_receive(:perform_async).with(subject.id)
      subject.forbid_card_access
    end
  end
end
