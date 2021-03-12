FactoryBot.define do
  factory :subscription do
    user
    subscription_plan

    start_at { Date.today }
    next_payment_at { Date.today + 1.month }

    locations { ["moliere", "maillot", "amelot"] }

    trait :running do
      after(:create) { |subscription| subscription.start! }
    end

    trait :with_commitment do
      commitment_period { 11 }
    end
  end
end
