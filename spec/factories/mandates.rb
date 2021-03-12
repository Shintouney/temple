# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :mandate do
    user
    slimpay_rum { "123456azerty" }
    slimpay_state { Mandate::SLIMPAY_STATE_CREATED }
    slimpay_created_at { "2015-08-06 16:49:08" }
    slimpay_order_state { Mandate::SLIMPAY_ORDER_COMPLETED }
  end
end
