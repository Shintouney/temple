class InvitationForm
  include ActiveModel::Model

  EMAIL_REGEXP = /\A\s*([-a-z0-9+._]{1,64})@((?:[-a-z0-9]+\.)+[a-z]{2,})\s*\z/i

  attr_accessor :to,
                :text

  validates :text, presence: true
  validates :to, presence: true
  validate :to_has_valid_emails

  private

  def to_has_valid_emails
    return unless to.present?
    to_emails = to.split(',').map(&:strip)

    to_emails.each do |to_email|
      unless to_email =~ EMAIL_REGEXP
        errors.add(:to, :has_invalid_emails)
        break
      end
    end
  end
end
