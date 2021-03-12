class User
  class CardUpdater
    include ActiveModel::Model

    attr_accessor :user, :card_reference, :referenced_user

    validates_presence_of :card_reference, :user

    validates_format_of :card_reference, with: CardScan::CARD_REFERENCE_FORMAT

    validate :card_reference_uniqueness

    # Validate the object and update the user card reference.
    #
    # Returns true if the user password is updated or false.
    def save
      return false unless valid?
      user.update_attributes(card_reference: card_reference)
      ResamaniaApi::PushUserWorker.perform_async(user.id)
      true
    end

    private

    def card_reference_uniqueness
      return unless user
      @referenced_user = User.where(card_reference: card_reference).where('id != ?', user.id).first
      return if @referenced_user.nil?
      errors.add(:base, :card_already_assigned)
    end
  end
end
