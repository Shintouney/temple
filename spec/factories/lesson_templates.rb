FactoryBot.define do
  factory :lesson_template do
    room { LessonTemplate.room.values.sample }
    sequence(:coach_name) { |i| "John Doe #{i}" }
    activity { "Boxe" }
    weekday { rand 1..7 }
    start_at_hour { Tod::TimeOfDay.new(rand(10..16), 30) }
    end_at_hour { start_at_hour + rand(1..3).hours }
    location { "moliere" }
  end
end
