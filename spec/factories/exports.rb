# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :export do
    state { 'in_progress' }
    export_type { 'invoice' }
    subtype { 'finished' }
    date_start { Date.today.advance(days: -5) }
    date_end { Date.today }

    trait :lesson_booking_export do
      export_type { 'lesson_booking' }
      subtype { 'finished' }
      date_start { Date.today.advance(days: -5) }
      date_end { Date.today }
    end

    trait :payment_export do
      export_type { 'payment' }
      subtype { 'debit' }
      date_start { Date.today.advance(days: -5) }
      date_end { Date.today }
    end
  end
end
