class AddPaymentModeToUser < ActiveRecord::Migration
  def change
    add_column :users, :payment_mode, :string, default: 'none'

    User.reset_column_information

    User.all.each do |user|
      next if [Settings.user.cash.email, Settings.user.cb.email, Settings.user.cheque.email, Settings.user.compensation.email].include?(user.email)
      if user.mandates.ready.any?
        user.payment_mode = 'sepa'
      elsif user.credit_cards.any?
        user.payment_mode = 'cb'
      end
      user.save!
    end
  end
end
