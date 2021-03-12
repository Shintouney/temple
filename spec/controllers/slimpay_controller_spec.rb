require 'rails_helper'

describe SlimpayController, type: :controller do
  let(:user) { FactoryBot.create :user, :with_registered_credit_card }
  let(:ipn_params) { { 'reference' => '123456azerty', 'state' => 'closed.completed', 'dateCreated' => Time.now } }

  describe 'ipn' do
    it 'does not support empty notifications' do
      post :ipn
      expect(response.status).to eq 400
    end
    it 'returns an error on unexisting Mandate reference' do
      JSON.should_receive(:parse) { ipn_params }
      Mandate.should_receive(:find_by) { nil }
      post :ipn, ipn_params
      expect(response.status).to eq 422
    end
    it 'updates the mandate' do
      mandate = double('Mandate.new')
      JSON.should_receive(:parse) { ipn_params }
      Mandate.should_receive(:find_by) { mandate }
      mandate.should_receive(:update_from_ipn).with(ipn_params)
      post :ipn, ipn_params
      expect(response.status).to eq 200
    end
  end

  describe 'sepa' do
    it 'creates a new order if no mandate exists', vcr: { cassette_name: 'slimpay_sepa' } do
      orders = double('Slimpay::Order.new')
      Slimpay::Order.should_receive(:new) { orders }
      orders.should_receive(:sign_mandate)
      Mandate.should_receive(:create) { Mandate.new(slimpay_approval_url: 'slimpay_test.com/approval_url') }
      post :sepa, user_id: user.id
    end
    context 'when a mandate already exists' do
      let!(:mandate) { FactoryBot.create :mandate, user: user }
      before do
        login_user(user)
      end
      it 'redirect_to user payment means' do
        post :sepa, user_id: user.id
        expect(response).to redirect_to account_payment_means_path
      end
      context 'when current_user is admin' do
        let(:admin) { FactoryBot.create :admin }
        before do
          logout_user
          login_user(admin)
        end
        it 'redirect_to adminUI user profile' do
          post :sepa, user_id: user.id
          expect(response).to redirect_to edit_admin_user_credit_card_path(user)
        end
      end
    end
  end

  describe "DELETE destroy" do
    let!(:mandate) { FactoryBot.create :mandate, user: user }
    let(:admin) { FactoryBot.create :admin }
    before do
      logout_user
      login_user(admin)
    end
    it 'mark the mandate as deleted' do
      expect do
        delete :destroy, id: mandate.id
      end.not_to change(Mandate, :count)
      expect(mandate.marked_as_deleted).to be false
    end
  end

  describe 'mandate_signature_return' do
    before do
      user.role = 2
      user.save
      user.reload
      login_user(user)
    end
    it 'renders with success' do
      get :mandate_signature_return
      expect(response).to be_success
    end
    it 'renders the confirmation page' do
      get :mandate_signature_return
      expect(response).to render_template 'mandate_signature_return'
    end
  end
end
