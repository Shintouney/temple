namespace :lessons do
  task create: :environment do
    Raven.capture do
      Lessons::CreateFromLessonTemplates.new.execute
    end
  end

  task create_for_a_week_from_now: :environment do
    (1..28).each do |index|
      Lessons::CreateFromLessonTemplates.new(Date.today, 2.week + index.day).execute
    end
  end
end
