require 'rails_helper'

describe ResamaniaApi::PushUser do
  let(:user) { FactoryBot.create(:user, :with_running_subscription, card_reference: 'DFE44D34F662D199') }

  subject { ResamaniaApi::PushUser.new(user) }

  describe '#user' do
    describe '#user' do
      it { expect(subject.user).to eql(user) }
    end
  end

  describe '#execute' do
    context "with a successful API call", vcr: { :cassette_name => "resamania_api/push_user_success" } do
      describe '#execute' do
        it { expect(subject.execute).to be true }
      end
    end

    context "with an API call returning a 404" do
      before do
        httparty_response_mock = double
        httparty_response_mock.should_receive(:code).twice.and_return(404)
        HTTParty.should_receive(:post).once.and_return(httparty_response_mock)
      end

      describe '#execute' do
        it { expect(subject.execute).to be false }
      end
    end

    context "with an API returning an exception" do
      before do
        HTTParty.should_receive(:post).once.and_raise(SocketError)
      end

      describe '#execute' do
        it { expect(subject.execute).to be false }
      end
    end
  end
end
