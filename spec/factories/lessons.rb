FactoryBot.define do
  factory :lesson do
    lesson_template
    room { lesson_template.room }
    coach_name { lesson_template.coach_name }
    activity { lesson_template.activity }
    start_at { (Date.today + rand(7..14).days).to_time + lesson_template.start_at_hour.to_i }
    end_at { start_at + rand(1..3).hours }
    max_spots { 4 }
    location { "moliere" }
  end
end
