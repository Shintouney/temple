FactoryBot.define do
  factory :suspended_subscription_schedule do
    user
    
    scheduled_at { Date.today }
    subscription_restart_date { Date.today + 5.days } 
  end
end
