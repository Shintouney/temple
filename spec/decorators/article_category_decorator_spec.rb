require 'rails_helper'

describe ArticleCategoryDecorator do
  describe '.collection_for_grouped_select' do
    let!(:article_categories) do
      [
        FactoryBot.create(:article_category, :with_article, name: 'DEF'),
        FactoryBot.create(:article_category, :with_article, name: 'ABC')
      ]
    end

    it "should fetch the categories" do
      collection = ArticleCategoryDecorator.collection_for_grouped_select

      expect(collection.length).to eql(2)
      expect(collection.first.name).to eql("ABC")
    end
  end
end
