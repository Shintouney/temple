class Users::AccessForbiddenJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    inactive_users = ::User.where(role: 2).inactive.select { |row_user| row_user.card_access == "authorized" && row_user.invalid_access_card? }
    inactive_users.each do |user|
      ::ResamaniaApi::PushUserWorker.perform_async(user.id) if user.update_attributes(card_access: 'forbidden')
    end
  end
end
