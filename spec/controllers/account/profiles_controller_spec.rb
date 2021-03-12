require 'rails_helper'

describe Account::ProfilesController do
  before { login_user(FactoryBot.create(:user, :with_profile)) }

  describe 'PATCH update' do
    subject { patch :update, profile: { 'user_attributes' => { 'linkedin_url' => 'plop' } } }

    context 'when bad arguments' do
      it 'redirects to the edit view' do
        expect(subject).to render_template(:edit)
        expect(subject.request.flash[:alert]).to_not be_nil
      end
    end
  end
end
