class UserImage < ActiveRecord::Base
  belongs_to :user
  validates :user, presence: true

  has_one :user_as_profile_user_image, foreign_key: :profile_user_image_id,
                                        dependent: :nullify,
                                        class_name: 'User'

  has_attached_file :image,
                    url: "/system/user_images/:id_partition/:hash.:extension",
                    hash_secret: Settings.upload.hash_secret,
                    styles: { miniature: '50x50#', thumbnail: "90x90#", carousel: '500x300#', card: "509x509#" }

  validates_attachment :image,
                        presence: true,
                        content_type: { content_type: /\Aimage/ },
                        file_name: { matches: [/png\Z/, /jpe?g\Z/] },
                        size: { in: 0..4.megabytes }
end
