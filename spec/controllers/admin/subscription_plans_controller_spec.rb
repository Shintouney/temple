require 'rails_helper'

describe Admin::SubscriptionPlansController, type: :controller do
  before { login_user(FactoryBot.create(:admin)) }

  let!(:subscription_plans) { FactoryBot.create_list(:subscription_plan, 10) }
  let(:subscription_plans_ids) { subscription_plans.map(&:id) }

  describe 'POST update_positions' do
    it 'reorders the SubscriptionPlans' do
      shuffled_ids = subscription_plans_ids[5..9] + subscription_plans_ids[0..4]

      post :update_positions, positions: shuffled_ids

      ordered_ids = SubscriptionPlan.order('position ASC').ids

      expect(response.body).to eql ordered_ids.to_json
      expect(ordered_ids).to eql shuffled_ids
    end
  end
end
