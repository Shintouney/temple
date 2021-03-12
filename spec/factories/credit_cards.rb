FactoryBot.define do
  factory :credit_card do
    firstname { 'John' }
    lastname { 'Doe' }
    number { '6385721812701293' }
    expiration_month { 6 }
    expiration_year { 2016 }
    brand { 'visa' }
    cvv { '772' }

    user

    trait :valid do
      firstname { 'John' }
      lastname { 'Doe' }
      number { '1111222233334444' }
      expiration_month { 2.years.from_now.month }
      expiration_year { 2.years.from_now.year }
      brand { 'visa' }
      cvv { '123' }
    end

    trait :registered do
      paybox_reference { 'SLDLrcsLMPC' }
    end
  end

  factory :activemerchant_credit_card, class: ActiveMerchant::Billing::CreditCard do
    first_name { 'John' }
    last_name { 'Doe' }
    number { '6385721812701293' }
    month { '06' }
    year { '2016' }
    brand { 'visa' }
    verification_value { '772' }

    trait :valid do
      number { '1111222233334444' }
      month { 2.years.from_now.month }
      year { 2.years.from_now.year }
      brand { 'visa' }
      verification_value { '123' }
    end
  end
end
