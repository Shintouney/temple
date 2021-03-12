class ArticleDecorator < ApplicationDecorator
  delegate_all

  # Public: The human-formatted price_ati.
  #
  # Returns a String.
  def price_ati
    formatted_price(object.price_ati)
  end

  # Public: The name and price of the object,
  # to use in a select tag.
  #
  # Returns a String.
  def name_for_select
    "#{name.ljust(40 - price_ati.length)} - #{price_ati}"
  end

  def image_thumbnail
    image_path = image.exists? ? image.url(:thumbnail) : '/assets/default-article-image.jpg'

    h.image_tag "/assets/default-article-image.jpg", class: 'lazy img-thumbnail', alt: name, data: { src: image_path }
  end
end
