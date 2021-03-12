FactoryBot.define do
  factory :lesson_booking do
    lesson
    user

    trait :past_lesson_booking do
      created_at { (Date.today - 2.days).to_time }
    end
  end
end
