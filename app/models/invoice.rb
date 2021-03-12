class Invoice < ActiveRecord::Base
  include AASM
  include StateMachineHelpers
  include TotalPricesCalculations

  DEFERRED_INVOICE_FIELDS = [:subscription_period_start_at, :subscription_period_end_at, :next_payment_at]

  belongs_to :user
  has_many :orders, -> { order(:created_at) }
  has_many :order_items, through: :orders
  has_and_belongs_to_many :payments

  validates :start_at, :end_at, presence: true
  validates(*DEFERRED_INVOICE_FIELDS, presence: true, if: :deferred?)
  validates :user, :user_firstname, :user_lastname, :user_street1, :user_postal_code, :user_city, presence: true

  scope :due, -> { where('next_payment_at <= ?', Date.today) }

  after_create :fill_billing_name, :fill_billing_address

  aasm column: :state do
    state :open, initial: true
    state :pending_payment, :pending_payment_retry, :canceled, :sepa_waiting, :paid, :refunded, :payment_not_needed

    event :cancel do
      transitions from: [:pending_payment, :pending_payment_retry], to: :canceled, after: lambda { self.canceled_at = DateTime.now } 
    end

    event :wait_for_payment do
      before { self.compute_total_price }
      transitions from: [:open, :pending_payment_retry, :sepa_waiting, :paid], to: :pending_payment
    end

    event :wait_for_payment_retry do
      transitions from: [:pending_payment, :sepa_waiting, :paid], to: :pending_payment_retry
    end

    event :accept_payment do
      transitions from: [:pending_payment, :pending_payment_retry, :sepa_waiting], to: :paid
    end

    event :refund do
      before do
        self.refunded_at = DateTime.now
        refunded_invoices = Invoice.with_state(:refunded).where("invoices.credit_note_ref IS NOT NULL")
        self.credit_note_ref = refunded_invoices.present? ? refunded_invoices.sort{|a, b| a.credit_note_ref <=> b.credit_note_ref}.last.credit_note_ref + 1 : 1
      end
      transitions from: :paid, to: :refunded
    end

    event :skip_payment do
      transitions from: :pending_payment, to: :payment_not_needed
    end

    event :mark_as_sepa do
      transitions from: [:open, :pending_payment, :pending_payment_retry], to: :sepa_waiting
    end
  end

  def chargeable?
    if deferred?
      (pending_payment? || pending_payment_retry?) && next_payment_at <= Date.today
    else
      (pending_payment? || pending_payment_retry?)
    end
  end

  # Public: Copy the relevant User attributes to the Invoice.
  #
  # Returns nothing.
  def copy_user_attributes
    self.user_firstname = user.firstname
    self.user_lastname = user.lastname
    self.user_street1 = user.street1
    self.user_street2 = user.street2
    self.user_postal_code = user.postal_code
    self.user_city = user.city
  end

  # Public: Update the total_price_ati value.
  #
  # Returns nothing.
  def compute_total_price
    self.total_price_ati = computed_total_price_ati
  end

  public :computed_total_price_te

  def self.pending
    with_state([:pending_payment, :pending_payment_retry])
  end

  def deferred?
    DEFERRED_INVOICE_FIELDS.map { |attribute_name| public_send(attribute_name) }.any?(&:present?)
  end

  private

  def fill_billing_name
    return if user.billing_name.nil?
    update_attribute :billing_name, user.billing_name
  end

  def fill_billing_address
    return if user.billing_address.nil?
    update_attribute :billing_address, user.billing_address
  end
end
