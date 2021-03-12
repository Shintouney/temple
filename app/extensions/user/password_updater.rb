class User
  class PasswordUpdater
    include ActiveModel::Model

    attr_accessor :user, :password, :password_confirmation

    validates_presence_of :user

    validates :password, presence: true, confirmation: true

    # Validate the object and update the user password.
    #
    # Returns true if the user password is updated or false.
    def save
      return false unless valid?

      user.password_confirmation = password
      user.change_password!(password)
    end
  end
end
