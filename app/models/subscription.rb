class Subscription < ActiveRecord::Base
  include AASM
  include StateMachineHelpers

  PERIODICITY = 1.month

  belongs_to :user
  validates :user, presence: true

  belongs_to :subscription_plan
  validates :subscription_plan, presence: true

  has_many :order_items, dependent: :nullify, as: :product

  scope :active, -> { with_state([:running, :temporarily_suspended]) }

  validates :start_at, presence: true
  validates :discount_period, numericality: { only_integer: true, allow_nil: true }

  aasm column: :state, whiny_transitions: false do
    state :pending, initial: true
    state :sepa_waiting, :replaced, :canceled, :temporarily_suspended
    state :running do
      #validate :start_at_not_in_future
    end

    event :start do
      transitions from: [:pending, :sepa_waiting, :temporarily_suspended], to: :running, after: lambda { self.user.authorize_card_access }
    end

    event :cancel do
      transitions from: [:running, :temporarily_suspended], to: :canceled, after: (lambda do
        invoice = self.user.invoices.with_state(:open).last
        if invoice.present? && (invoice.end_at >= Date.today)
          self.update_attribute :end_at, invoice.end_at
        else
          self.user.update_attributes(card_access: :forbidden)
        end
        ResamaniaApi::PushUserWorker.perform_async(self.user.id)
      end)
    end

    event :temporarily_suspend do
      transitions from: :running, to: :temporarily_suspended, if: lambda { self.restart_date.present? }, after: lambda { self.update_suspended_subscription }
    end

    event :restart do
      transitions from: :temporarily_suspended, to: :running, after: lambda { self.user.authorize_card_access }
    end

    event :replace do
      transitions from: :running, to: :replaced, after: lambda { self.update_attribute :replaced_date, Date.today }
    end

    event :start_sepa do
      transitions from: :pending, to: :sepa_waiting
    end
  end

  serialize :locations, Array
  after_initialize :set_default_locations

  def default_locations
    ['moliere', 'maillot', 'amelot']
  end

  def set_default_locations
    self.locations ||= default_locations
  end

  # Public: set default value for locations.
  #
  # Returns a string.
  def locations
    self[:locations] ||= default_locations
  end

  # Public: Is the subscription under a commitment period?
  #
  # Returns a Boolean.
  def commitment_running?
    commitment_period > 0
  end

  # Public: Is the subscription under a discount period?
  #
  # Returns a Boolean.
  def discount_running?
    !discount_period.nil? && discount_period > 0
  end

  # Public: Get the start Date of the current period covered by the Subscription.
  #
  # Returns a Date.
  def current_period_start_date
    Date.new(Date.today.year, Date.today.month, current_day_start_date)
  end

  # Public: Get the end Date of the current period covered by the Subscription.
  #
  # Returns a Date.
  def current_period_end_date
    next_period = current_period_start_date + PERIODICITY
    if (Date.today.month == 1 && start_at.day >= 29) || start_at.day == 31
      # In january, the next month will be February: special rule
      next_period.end_of_month - 1.day
    else
      Date.new(next_period.year, next_period.month, start_at.day) - 1.day
    end
  end

  # Public Update subscription after beeing suspended
  #
  # Return a Boolean
  def update_suspended_subscription
    user.forbid_card_access
    if user.current_deferred_invoice.present?
      user.current_deferred_invoice.update_attributes(next_payment_at: Date.today, end_at: Date.today)
    end
    update_attribute(:suspended_at, Date.today)
  end

  # Public: Get the date of end of commitment without suspension
  #
  # Return a Date
  def commitment_period_origin
    I18n.l(created_at.advance(months: subscription_plan.commitment_period).to_date)
  end

  # Public: Return the date of end of commitment set after suspension
  #
  # Return a Date
  def end_of_commitment
    user.invoices.with_state(:open).last.next_payment_at.advance(months: commitment_period - 1)
  end

  private

  def start_at_not_in_future
    return if start_at_reached?
    errors.add(:start_at, :must_be_in_past_or_present)
  end

  def start_at_reached?
    start_at.present? && start_at <= Date.today
  end

  def current_day_start_date
    if (Date.today.month == 2 && start_at.day >= 30) || start_at.day == 31
      today_or_end_of_month
    else
      start_at.day
    end
  end

  def today_or_end_of_month
    if (Date.today.month == 2 && start_at.day >= 30)
      Date.today.end_of_month.day
    elsif Date.today.day == 30 && Date.today.end_of_month.day == 31
      30
    else
      Date.today.day
    end
  end
end
