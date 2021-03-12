FactoryBot.define do
  factory :order_item do
    order
    association :product, factory: :subscription_plan

    trait :validated do
      product_name { "Snack" }
      product_price_ati { rand(10..200) }
      product_price_te { (product_price_ati * (1 / ((100 + product_taxes_rate) / 100))).round(2) }
      product_taxes_rate { 20.0 }
    end

    trait :from_article do
      association :product, factory: :article
    end
  end
end
