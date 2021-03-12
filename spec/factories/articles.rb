FactoryBot.define do
  factory :article do
    price_ati { rand(10..200) }
    taxes_rate { 20.0 }
    price_te { (price_ati * (1 / ((100 + taxes_rate) / 100))).round(2) }

    sequence(:name) { |i| "Article #{i}" }

    article_category

    image_file_name { 'sample.jpg' }
    image_content_type { 'image/jpg' }
    image_file_size { 1024 }
    image_updated_at { Time.now }
    visible { true }
  end
end
