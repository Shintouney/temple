class Users::CheckJob < ActiveJob::Base
  queue_as :default

  # Checking users without payment state (none instead of cb or sepa)
  def perform
    users_hash = check_users
    ::ApplicationController.helpers.display_results(users_hash)
    ::AdminMailer.invalid_users(users_hash, :payment_mode).deliver_later if users_hash.any?
  end

  private

  def check_users
    users_hash = {}
    users = ::User.where(payment_mode: 'none')
    users.joins(:credit_cards).select{ |user| user.credit_cards.any? && user.credit_cards.last.valid? }.each do |user|
      users_hash[user.id] = "A user with a CB is marked as payment_mode 'none', should be 'cb'"
    end
    users.joins(:mandates).select{ |user| user.mandates.any? && user.mandates.last.ready? }.each do |user|
      users_hash[user.id] = "A user with a SEPA mandate is marked as payment_mode 'none', should be 'sepa'"
    end
    users_hash
  end
end
