FactoryBot.define do
  factory :subscription_plan do
    price_te { rand(120..150) }
    taxes_rate { 20 }
    price_ati { (price_te.to_f * (100 + taxes_rate) / 100).round(2) }
    displayable { true }
    discount_period { 0 }
    commitment_period { 0 }

    sequence(:name) { |i| "Plan #{i}" }

    locations { ["moliere", "maillot", "amelot"] }

    trait :discounted do
      discount_period { 3 }
      discounted_price_te { rand(100..110) }
      discounted_price_ati { (discounted_price_te.to_f * (100 + taxes_rate) / 100).round(2) }
    end

    trait :with_sponsorship do
      discount_period { 3 }
      sponsorship_price_te { rand(100..110) }
      sponsorship_price_ati { (sponsorship_price_te.to_f * (100 + taxes_rate) / 100).round(2) }
    end
  end
end
