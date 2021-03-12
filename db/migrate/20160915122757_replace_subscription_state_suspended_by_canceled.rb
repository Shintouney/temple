class ReplaceSubscriptionStateSuspendedByCanceled < ActiveRecord::Migration
  def change
    Subscription.where(state: :suspended).each do |subscription|
      subscription.update_attribute(:state, :canceled)
    end
  end
end
