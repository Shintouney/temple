class ArticleCategory < ActiveRecord::Base
  has_many :articles, -> { order('name ASC') }, dependent: :nullify

  validates :name, presence: true

  scope :ordered_by_name, -> { order('name ASC') }
end
