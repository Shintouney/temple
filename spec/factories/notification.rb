FactoryBot.define do
  factory :notification do
    user
    sourceable_type { 'Lesson' }
  end
end
