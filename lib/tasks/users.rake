namespace :users do
  desc "Check users"
  task check: :environment do
    puts "Checking users without payment state (none instead of cb or sepa)"
    users_hash = check_users
    display_results(users_hash)
    AdminMailer.invalid_users(users_hash, :payment_mode).deliver_later if users_hash.any?
  end

  desc "Invalid users access card"
  task access_forbidden: :environment do
    inactive_users = User.where(role: 2).inactive.select {|i| i.card_access == "authorized"}

    inactive_users.each do |user|
      if user.invalid_access_card?
        user.update_attributes!(card_access: 'forbidden')
        ResamaniaApi::PushUserWorker.perform_async(user.id)
      end
    end
  end

  desc "Update groups"
  task update_groups: :environment do
    Group.all.each do |group|
      GroupWorker.perform_async(group.id)
    end
  end

  private

  def check_users
    users_hash = {}
    users = User.where(payment_mode: 'none')
    users.joins(:credit_cards).select{ |user| user.credit_cards.any? && user.credit_cards.last.valid? }.each do |user|
      users_hash[user.id] = "A user with a CB is marked as payment_mode 'none', should be 'cb'"
    end
    users.joins(:mandates).select{ |user| user.mandates.any? && user.mandates.last.ready? }.each do |user|
      users_hash[user.id] = "A user with a SEPA mandate is marked as payment_mode 'none', should be 'sepa'"
    end
    users_hash
  end
end
