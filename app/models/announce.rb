class Announce < ActiveRecord::Base
  extend Enumerize

  belongs_to :group

  has_attached_file :file,
                    url: "/system/announce_images/:id_partition/:hash.:extension",
                    hash_secret: Settings.upload.hash_secret,
                    styles: { thumbnail: "400x150#" }

  enumerize :place, in: { all: 'all', dashboard: 'dashboard'}

  validates_attachment :file,
                        content_type: { content_type: /\Aimage/ },
                        file_name: { matches: [/png\Z/, /jpe?g\Z/] },
                        size: { in: 0..4.megabytes },
                        allow_blank: true

  validates :target_link, format: { with: /\A.+\..+{2,}\z/ }, allow_blank: true

  validate :has_any_content
  validate :start_before_end

  scope :current, -> { where('start_at <= ? AND end_at >= ?', Date.today, Date.today) }
  scope :active, -> { where(active: true) }
  scope :for_dashboard, -> { where(place: 'dashboard') }
  scope :for_all, -> { where(place: 'all') }

  private

  def has_any_content
    return if content.present? || file?
    errors.add(:content, :any_content)
    errors.add(:file, :any_content)
  end

  def start_before_end
    return if start_at.blank? || end_at.blank?
    return if  start_at <= end_at
    errors.add(:start_at, :before_end_at)
  end
end
