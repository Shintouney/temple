require 'rails_helper'

describe ResamaniaApi::PushUserWorker do
  let(:user) { FactoryBot.create(:user) }

  describe '#perform' do
    it 'should perform a call to ResamaniaApi::PushUserWorker' do
      push_user = double
      push_user.should_receive(:execute)
      ResamaniaApi::PushUser.should_receive(:new).with(user).and_return(push_user)
      subject.perform(user.id)
    end
  end
end
