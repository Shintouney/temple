require 'rails_helper'

describe ResamaniaApi::DeleteUserWorker do
  let(:user) { FactoryBot.create(:user) }

  describe '#perform' do
    it 'should perform a call to ResamaniaApi::DeleteUser' do
      delete_user = double
      delete_user.should_receive(:execute)
      ResamaniaApi::DeleteUser.should_receive(:new).with(user.id).and_return(delete_user)
      subject.perform(user.id)
    end
  end
end
