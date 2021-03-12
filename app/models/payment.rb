class Payment < ActiveRecord::Base
  include AASM
  include StateMachineHelpers

  WAITING_TO_PROCESS = 'toprocess'.freeze
  SLIMPAY_WAITERS = ['processing', WAITING_TO_PROCESS].freeze
  SLIMPAY_REJECTIONS = ['rejected', 'notprocessed', 'contested'].freeze

  belongs_to :user
  belongs_to :credit_card

  has_and_belongs_to_many :invoices

  validates :price, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  validate :paid_unicity_for_invoice, on: :create

  attr_writer :activemerchant_credit_card

  aasm column: :state, whiny_transitions: false do
    state :transaction_pending, initial: true
    state :waiting_slimpay_confirmation, :accepted, :declined

    event :accept do
      transitions from: [:transaction_pending, :waiting_slimpay_confirmation], to: :accepted
    end

    event :wait_slimpay_confirmation do
      transitions from: :transaction_pending, to: :waiting_slimpay_confirmation
    end

    event :decline do
      transitions from: [:transaction_pending, :waiting_slimpay_confirmation, :accepted], to: :declined
    end
  end

  # Public: Compute the price value.
  #
  # Returns nothing.
  def compute_price
    self.price = invoices.to_a.sum(&:total_price_ati)
  end

  def is_slimpay_payment?
    self.slimpay_direct_debit_id.present?
  end

  private

  def paid_unicity_for_invoice
    return if invoices.blank? || invoices.first.payments.with_state([:accepted, :waiting_slimpay_confirmation]).count == 0
    errors.add(:unicity, "This payment's invoice already have an accepted payment ")
  end
end
