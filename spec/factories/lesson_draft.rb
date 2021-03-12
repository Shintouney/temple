FactoryBot.define do
  factory :lesson_draft do
    room { LessonDraft.room.values.sample }
    coach_name { "John Doe" }
    activity { "Boxe" }
    weekday { rand 1..7 }
    start_at_hour { Tod::TimeOfDay.new(rand(10..16), 30) }
    end_at_hour { start_at_hour + rand(1..3).hours }
    location { "moliere" }
  end
end
