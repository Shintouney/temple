class SponsoringRequest < ActiveRecord::Base
  belongs_to :user

  validates :email, email: true, presence: true
  validates :firstname, :lastname, :phone, :user, presence: true
end
