FactoryBot.define do
  factory :visit do
    user
    started_at { DateTime.new 2014, 3, 13, 18, 19, 0 }
    ended_at { started_at + 1.hour }

    location { 'moliere' }

    trait :in_progress do
      ended_at { nil }
    end
  end
end
