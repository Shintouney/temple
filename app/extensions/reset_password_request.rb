class ResetPasswordRequest
  include ActiveModel::Model

  attr_reader :email, :user

  validates_presence_of :user

  # Email attribute writer.
  # The corresponding user record will be fetched and
  # its attribute set if possible.
  #
  # Returns the attribute value.
  def email=(email)
    @email = email
    @user = User.find_by_email(email) if @email.present?
  end
end
