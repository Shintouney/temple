class UnsubscribeRequest < ActiveRecord::Base
  validates :email, email: true, presence: true
  validates :firstname, :lastname, :phone, :desired_date, presence: true

  validate :reason_must_be_filled

  private

  def reason_must_be_filled
    return true if health_reason.present?  || moving_reason.present? || other_reason.present?
    errors.add :reason_must_be_filled, 'must be filled'
  end
end
