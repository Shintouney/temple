require 'rails_helper'

describe Admin::CreditCardsController, type: :controller do
  before { login_user(FactoryBot.create(:admin)) }

  describe 'edit' do
    let!(:user) { FactoryBot.create(:user, :with_mandate) }

    it 'refresh the mandate', vcr: { cassette_name: 'slimpay_admin_edit_refresh' } do
      expect(user.mandates.last).not_to be_nil
      Mandate.any_instance.should_receive(:refresh)
      get :edit, user_id: user.id
    end

    context 'when exceptions' do
      let(:error) { { code: 666, message: 'test_error' }.to_json }
      before  do
        Mandate.any_instance.should_receive(:refresh) { raise Slimpay::Error.new(error) }
      end
      it 'flashes on rescue' do
        get :edit, user_id: user.id
        expect(flash.now[:alert]).not_to be_nil
        expect(flash.now[:alert]).to match(I18n.t('admin.credit_cards.edit.cannot_refresh_mandate'))
      end
    end
  end
end
