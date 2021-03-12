module Helpers
  def create_subscribed_user(subscription_plan = nil)
    subscription_plan = FactoryBot.create(:subscription_plan) unless subscription_plan
    user = FactoryBot.build(:user)
    user.current_credit_card = FactoryBot.build(:credit_card, :valid, :registered, user: user)
    user.save!

    subscribe_user(user, subscription_plan)

    user.reload
  end

  def subscribe_user(user, subscription_plan)
    subscribe_user = User::Subscribe.new(user, subscription_plan, user.current_credit_card.to_activemerchant)

    subscribe_user.send(:create_invoice)
    subscribe_user.send(:create_subscription)
    subscribe_user.send(:create_order)
    subscribe_user.invoice.wait_for_payment!
    subscribe_user.send(:set_paybox_user_reference)

    validate_invoice_payment(subscribe_user.invoice)

    subscribe_user.subscription.start!
    Invoice::Deferred::Create.new(user.reload).execute
  end

  def validate_invoice_payment(invoice)
    charge_invoice = Invoice::Charge.new(invoice)
    charge_invoice.send(:build_payment)
    payment = charge_invoice.payment

    payment.accept!

    invoice.accept_payment!
  end

  def fail_order_payment(order, user)
    payment = Payment.new(invoices: [order.invoice], user: user, credit_card: user.current_credit_card)

    payment.decline!
  end

  # Public: The list of emails being sent by the application.
  # This method helps abstracting the email delivery
  # mecanisms.
  #
  # Returns an Array of email jobs.
  def email_queue
    Sidekiq::Queue.new("mailers")
  end
end

RSpec.configure do |config|
  config.include Helpers

  # rspec-rails 3 will no longer automatically infer an example group's spec type
  # from the file location. You can explicitly opt-in to the feature using this
  # config option.
  # To explicitly tag specs without using automatic inference, set the `:type`
  # metadata manually:
  #
  #     describe ThingsController, :type => :controller do
  #       # Equivalent to being in spec/controllers
  #     end
  config.infer_spec_type_from_file_location!
end
