require 'rails_helper'

describe Admin::VisitsController, type: :controller do
  before { login_user(FactoryBot.create(:admin)) }

  let!(:user) { FactoryBot.create(:user, firstname: 'Syrio', lastname: 'Forel') }

  before { FactoryBot.create(:subscription, user: user, state: 'running') }

  describe 'GET index as JSON' do
    let!(:visits) { FactoryBot.create_list(:visit, 5, :in_progress, started_at: Time.now) }

    it 'does not create a new visit' do
      xhr :get, :index, format: :json

      json_response = JSON.parse(response.body)
      expect(json_response.length).to eql(visits.length)
      expect(json_response.first.keys.sort).to eql(['html', 'id'])
    end
  end

  describe 'POST create' do
    context 'with a valid request' do
      it 'creates a new visit' do
        visits_count = Visit.count

        post :create, visit: {user_id: user.id, location: 'moliere'}

        expect(Visit.count).to eql(visits_count + 1)

        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
      end
    end

    context 'with an invalid request' do
      it 'does not create a new visit' do
        visits_count = Visit.count

        post :create, visit: { user_id: nil }

        expect(Visit.count).to eql(visits_count)

        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response.key?('flash')).to be true
      end
    end
  end

  describe 'GET search_user_by_name' do
    context 'with an existing user firstname' do
      it 'returns matching users' do
        get :search_user_by_name, name: 'Syrio'

        json_response = (JSON.parse(response.body))

        expect(json_response.first['id']).to eql(user.id)
        expect(json_response.first['value']).to eql('Syrio Forel')
      end
    end

    context 'with an existing user lastname' do
      it 'returns matching users' do
        get :search_user_by_name, name: 'Forel'

        json_response = (JSON.parse(response.body))

        expect(json_response.first['id']).to eql(user.id)
        expect(json_response.first['value']).to eql('Syrio Forel')
      end
    end

    context 'with non existing user firstname or lastname' do
      it 'returns empty list' do
        get :search_user_by_name, name: 'Syriio'

        json_response = (JSON.parse(response.body))

        expect(json_response).to be_empty
      end
    end

    context 'with the name of a staff user' do
      let!(:staff_user) { FactoryBot.create(:staff, firstname: 'Janitor', lastname: 'Employee') }

      it 'returns empty list' do
        get :search_user_by_name, name: 'Janitor'

        json_response = (JSON.parse(response.body))

        expect(json_response).to be_empty
      end
    end

    context 'with the name of an inactive_user user' do
      let!(:inactive_user) { FactoryBot.create(:user, firstname: 'Didnot', lastname: 'Pay') }

      before { FactoryBot.create(:subscription, user: inactive_user, state: 'canceled') }

      it 'returns empty list' do
        get :search_user_by_name, name: 'Didnot'

        json_response = (JSON.parse(response.body))

        expect(json_response).to be_empty
      end
    end
  end
end
