# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :announce, :class => 'Announce' do
    content { 'Lorem ipsum dolor sit amet consectur adpicing elit' }
    file { nil }
    target_link { nil }
    external_link { false }
    start_at { Time.zone.now.advance(days: -1) }
    end_at { Time.zone.now.advance(days: 3) }
    active { false }
    place { 'all' }

    trait :banner do
      content { nil }
      file_file_name { 'sample.jpg' }
      file_content_type { 'image/jpg' }
      file_file_size { 1024 }
    end
  end
end
