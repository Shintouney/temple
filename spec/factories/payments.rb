FactoryBot.define do
  factory :payment do
    user
    trait :with_credit_card do
      credit_card
    end

    trait :with_accepted_credit_card do
      credit_card
      state { 'accepted' }
      paybox_transaction { "00111245120095214521" }
      created_at { Time.zone.now.advance(days: -2) }
    end
  end
end
