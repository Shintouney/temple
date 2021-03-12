FactoryBot.define do
  factory :invoice do
    start_at { Date.today }
    end_at { Date.today }
    subscription_period_start_at { Date.today }
    subscription_period_end_at { Date.today }
    next_payment_at { Date.today }

    user

    after(:build) do |invoice| 
      invoice.copy_user_attributes
    end

    trait :with_accepted_invoice do
      after(:build) { |invoice| invoice.payments << FactoryBot.create(:payment, :with_accepted_credit_card) }
    end
  end
end
