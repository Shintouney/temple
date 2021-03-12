class Article < ActiveRecord::Base
  include Product

  belongs_to :article_category
  has_many :order_items, dependent: :nullify, as: :product

  has_attached_file :image,
                    url: "/system/article_images/:id_partition/:hash.:extension",
                    hash_secret: Settings.upload.hash_secret,
                    styles: { thumbnail: "50x50#" }

  validates_attachment :image,
                        presence: true,
                        content_type: { content_type: /\Aimage/ },
                        file_name: { matches: [/png\Z/, /jpe?g\Z/] },
                        size: { in: 0..4.megabytes }

  scope :visible, ->{ where(visible: true) }

  before_save :ensure_legal_quoting

  private
  def ensure_legal_quoting
    self.name = self.name.gsub('"', "'")
  end
end
