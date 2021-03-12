FactoryBot.define do
  factory :user do
    sequence(:email) { |i| "#{SecureRandom.hex(6)}-#{i}@example.com" }

    password { "ABCD1234" }
    password_confirmation { password }

    sequence(:firstname) { |i| "Jean #{i}" }
    sequence(:lastname) { |i| "Dupond #{i}" }

    street1 { "1 Rue du Pont" }
    street2 { nil }
    postal_code { '75010' }
    city { "Paris" }
    country_code { "fr" }
    billing_name { "CE de Mr Dupond" }
    billing_address { "Adresse du CE de Mr Dupond" }

    phone { "0600000000" }

    birthdate { Date.today - rand(20..40).years }
    gender { User.gender.values.sample }

    card_access { :authorized }

    payment_mode { 'sepa' }

    factory :admin do
      role { :admin }
      location { 'moliere' }
    end

    factory :staff do
      role { :staff }
      location { 'moliere' }

      sequence(:card_reference) { |i| "#{SecureRandom.hex(7)}#{sprintf('%02d', i)}".upcase }
    end

    trait :with_registered_credit_card do
      association :current_credit_card, factory: [:credit_card, :registered]
    end

    trait :with_mandate do
      after(:create) { |user| user.mandates << FactoryBot.create(:mandate, user: user) }
    end

    trait :with_profile do
      after(:build) { |user| user.build_profile }
    end

    trait :with_running_subscription do
      after(:create) { |user| user.subscriptions << FactoryBot.create(:subscription, :running, user: user)}
    end
  end
end
