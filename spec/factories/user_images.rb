FactoryBot.define do
  factory :user_image do
    user

    image_file_name { 'sample.jpg' }
    image_content_type { 'image/jpg' }
    image_file_size { 1024 }
    image_updated_at { Time.now }
  end
end
