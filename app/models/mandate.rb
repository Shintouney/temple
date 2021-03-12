class Mandate < ActiveRecord::Base
  SLIMPAY_STATE_CREATED = 'active'
  SLIMPAY_ORDER_WAITING = 'open.running'
  SLIMPAY_ORDER_COMPLETED = 'closed.completed'
  SLIMPAY_ORDER_ABORTED = 'closed.aborted'
  SLIMPAY_ORDER_ABORTED_CLIENT = 'closed.aborted.aborted_byclient'
  SLIMPAY_ORDER_ABORTED_SERVER = 'closed.aborted.aborted_byserver'

  belongs_to :user

  scope :ready, lambda{
    where(slimpay_state: SLIMPAY_STATE_CREATED, marked_as_deleted: false)
    .where(slimpay_order_state: SLIMPAY_ORDER_COMPLETED)
    .where('slimpay_rum IS NOT NULL')
  }

  def self.sign(user)
    begin
      slim_orders = Slimpay::Order.new
      order = slim_orders.sign_mandate(user.id, signatory(user))
    rescue StandardError => exception
      Raven.capture_exception(exception, extra: { context: 'Mandate.sign' }, user: { id: user.id, email: user.email })
      return false
    end

    mandate = Mandate.create(user_id: user.id) do |new_mandate|
      new_mandate.slimpay_order_reference = order['reference']
      new_mandate.slimpay_order_state = order['state']
      new_mandate.slimpay_approval_url = slim_orders.api_methods['user_approval']
    end
    mandate
  end

  def self.signatory(user)
    {
      honorificPrefix: user.male? ? 'Mr' : 'Mrs',
      familyName: user.lastname.gsub(/\d|_/, ''),
      givenName: user.firstname.gsub(/\d|_/, ''),
      telephone: user.slimpay_formated_phone,
      email: user.email,
      billingAddress: {
        street1: user.street1,
        street2: user.street2,
        postalCode: user.postal_code,
        city: user.city,
        country: user.country_code.upcase
      }
    }
  end

  def ready?
    slimpay_rum.present? && !marked_as_deleted? && slimpay_state.eql?(SLIMPAY_STATE_CREATED) && slimpay_order_state.eql?(SLIMPAY_ORDER_COMPLETED)
  end

  def waiting?
    slimpay_order_state.eql?(SLIMPAY_ORDER_WAITING)
  end

  def showable?
    (self.waiting? || self.ready?) && !self.marked_as_deleted?
  end

  # Debits & subscription start if all OK
  def update_from_ipn(ipn_hash)
    return if ipn_hash.blank?
    self.update_attributes! slimpay_order_state: ipn_hash['state'], slimpay_created_at: ipn_hash['dateCreated']
    return unless ipn_hash['state'].eql?('closed.completed')
    retrieve_rum
    return if user.active? || user.credit_cards.any?
    return unless make_first_payment
    self.user.subscriptions.pending.last.start!
    update_user_payment_mode
    Invoice::Deferred::Create.new(user.reload).execute
  end

  def refresh
    return refresh_from_order if slimpay_rum.nil?
    m = Slimpay::Mandate.new
    remote_mandate_hash = begin
      JSON.parse(m.get_one(self.slimpay_rum))
    rescue Slimpay::Error => e
      e.to_s
    end
    return if remote_mandate_hash['dateRevoked'].blank?
    self.update_attributes slimpay_revoked_at: remote_mandate_hash['dateRevoked'], slimpay_state: 'revoked'
    if slimpay_revoked_at.present? && slimpay_state == 'revoked'
      user.update_attributes(payment_mode: user.current_credit_card.present? ? 'cb' : 'none')
    end
  end

  private

  def retrieve_rum
    remote_orders = Slimpay::Order.new
    remote_orders.get_one(slimpay_order_reference)
    remote_mandate = JSON.parse(remote_orders.get_mandate)
    self.update_attributes slimpay_rum: remote_mandate['rum'], slimpay_state: remote_mandate['state'], slimpay_created_at: remote_mandate['dateCreated']
    user.update_attributes(payment_mode: 'sepa') if slimpay_rum.present? && slimpay_state == SLIMPAY_STATE_CREATED
  end

  def make_first_payment
    invoice = Invoice.new(start_at: Date.today, end_at: Date.today, user: user)
    invoice.copy_user_attributes
    last_pending_subscription = user.subscriptions.with_state(:pending).last
    if last_pending_subscription.present?
      Order::CreateFromSubscription.new(invoice, last_pending_subscription).execute
      invoice.wait_for_payment!
      Invoice::Charge.new(invoice).execute
    end
  end

  def refresh_from_order
    slimpay_orders = Slimpay::Order.new
    remote_order = slimpay_orders.get_one(slimpay_order_reference)
    remote_order_hash = JSON.parse(remote_order)
    return if remote_order_hash['state'] != SLIMPAY_ORDER_COMPLETED
    remote_mandate = JSON.parse(slimpay_orders.get_mandate)
    self.update_attributes slimpay_order_state: SLIMPAY_ORDER_COMPLETED,
                            slimpay_rum: remote_mandate['rum'],
                            slimpay_state: remote_mandate['state'],
                            slimpay_created_at: remote_mandate['dateCreated']
    user.subscriptions.last.start! if user.subscriptions.last.sepa_waiting? || user.subscriptions.last.pending?
    update_user_payment_mode
  end

  def update_user_payment_mode
    user.update_attribute :payment_mode, :sepa
  end
end
