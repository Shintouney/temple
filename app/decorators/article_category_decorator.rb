class ArticleCategoryDecorator < ApplicationDecorator
  delegate_all

  decorates_association :articles

  # Public: Fetches and decorates the Article records.
  #
  # Returns an Enumerable.
  def self.collection_for_grouped_select
    decorate_collection(
      ArticleCategory.includes(:articles)
                      .where('articles.visible IS TRUE')
                      .order('article_categories.name ASC, articles.name ASC')
                      .references(:comments)
    )
  end
end
