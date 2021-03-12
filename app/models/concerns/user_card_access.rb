module UserCardAccess
  extend ActiveSupport::Concern

  included do
  end

  def authorize_card_access
    update_attributes(card_access: :authorized)
    ResamaniaApi::PushUserWorker.perform_async(id)
  end

  def forbid_card_access
    unless card_access.forced_authorized?
      update_attributes(card_access: :forbidden)
      ResamaniaApi::PushUserWorker.perform_async(id)
    end
  end
end
