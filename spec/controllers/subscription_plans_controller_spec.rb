require 'rails_helper'

describe SubscriptionPlansController, type: :controller do
  let!(:subscription_plans) do
      [
        FactoryBot.create(:subscription_plan, position: 1, displayable: true, name: 'Displayable plan 1'),
        FactoryBot.create(:subscription_plan, position: 2, displayable: true, name: 'Displayable plan 2')
      ]
  end

  render_views

  describe '#embed' do
    it 'displays the subscription plans' do
      post :embed

      expect(response.body).to include('Displayable plan 1')
      expect(response.body).to include('Displayable plan 2')

      expect(response).to render_template('embed')
      expect(response).to render_template(layout: false)

      expect(response.headers['Access-Control-Allow-Origin']).to eql('*')
    end
  end
end
