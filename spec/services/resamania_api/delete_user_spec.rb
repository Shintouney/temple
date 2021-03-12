require 'rails_helper'

describe ResamaniaApi::DeleteUser do
  let(:user) { FactoryBot.create(:user, card_reference: 'A4E8ED34A162D191', id: 90000) }

  subject { ResamaniaApi::DeleteUser.new(user.id) }

  describe '#user' do
    describe '#user_id' do
      it { expect(subject.user_id).to eql(user.id) }
    end
  end

  describe '#execute' do
    context "with a successful API call", vcr: { :cassette_name => "resamania_api/delete_user_success" } do
      describe '#execute' do
        it { expect(subject.execute).to be true }
      end
    end

    context "with an API call returning a 404" do
      before do
        httparty_response_mock = double
        httparty_response_mock.should_receive(:code).twice.and_return(404)
        HTTParty.should_receive(:delete).once.and_return(httparty_response_mock)
      end

      describe '#execute' do
        it { expect(subject.execute).to be false }
      end
    end

    context "with an API returning an exception" do
      before do
        HTTParty.should_receive(:delete).once.and_raise(SocketError)
      end

      describe '#execute' do
        it { expect(subject.execute).to be false }
      end
    end
  end
end
