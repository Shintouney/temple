FactoryBot.define do
  factory :article_category do
    sequence(:name) { |i| "Category #{i}" }

    trait :with_article do
      after(:build) { |article_category| article_category.articles << FactoryBot.create(:article) }
    end
  end
end
