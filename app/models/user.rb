class User < ActiveRecord::Base
  extend Enumerize
  include UserCardAccess

  authenticates_with_sorcery!

  CREATION_ATTRIBUTES = [:email, :password, :password_confirmation,
                         :firstname, :lastname,
                         :street1, :street2, :postal_code, :city, :country_code,
                         :phone, :birthdate, :gender,
                         :facebook_url, :linkedin_url, :professional_sector,
                         :position, :company, :professional_address, :education,
                         :heard_about_temple_from, :professional_zipcode,
                         :professional_city, :receive_mail_ical, :receive_booking_confirmation]

  TEMPLE_GHOSTS = [Settings.user.cash.email, Settings.user.cb.email, Settings.user.cheque.email, Settings.user.ghost_one.email, Settings.user.ghost_two.email, Settings.user.compensation.email]

  default_scope { where(:deactivated_at => nil) }

  has_many :credit_cards
  belongs_to :current_credit_card, class_name: 'CreditCard'

  has_many :notifications
  has_many :orders, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_one :current_subscription, -> { with_state(:running).order('start_at DESC') }, class_name: 'Subscription'
  has_many :payments, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :visits, dependent: :destroy
  has_many :card_scans, dependent: :destroy
  belongs_to :current_deferred_invoice, class_name: 'Invoice'

  has_many :user_images, dependent: :destroy
  belongs_to :profile_user_image, class_name: 'UserImage'

  belongs_to :sponsor, class_name: 'User'
  has_many :sponsored_users, class_name: 'User', foreign_key: :sponsor_id

  has_many :lesson_bookings
  has_many :lessons, through: :lesson_bookings

  has_one :profile

  has_many :mandates

  has_and_belongs_to_many :groups

  before_validation :format_email

  validates :email, presence: true, email: true, uniqueness: { case_sensitive: false }

  validates :password, presence: true, on: :create, unless: :staff?
  validates :password, confirmation: true, if: ->(record) { record.password.present? }
  validates :password_confirmation, presence: true, if: ->(record) { record.password.present? }
  validate :password_matches_format

  validates :firstname, :lastname, presence: true

  validates :street1, :postal_code, :city, :phone, :birthdate, :gender, presence: true, if: :user?
  validates :card_reference, presence: true, if: :staff?

  validates :card_reference, format: { with: CardScan::CARD_REFERENCE_FORMAT, allow_blank: true }
  validates :card_reference, uniqueness: { allow_blank: true, case_sensitive: false }

  validates :facebook_url, allow_blank: true, format: { with: %r(\A((http|https):\/\/){0,1}([^\.:]*\.){0,1}facebook\.com\/.*\z) }

  validates :linkedin_url, allow_blank: true, format: { with: %r(\A((http|https):\/\/){0,1}([^\.:]*\.){0,1}(linkedin\.com|lnkd\.in)\/.*\z) }

  validate :uniq_planning_access_bypass

  enumerize :role, in: {admin: 1, user: 2, staff: 3}, default: :user, scope: true, predicates: true

  enumerize :gender, in: {male: 'M', female: 'F'}, predicates: true

  enumerize :card_access, in: {authorized: 1, forbidden: 2, forced_authorized: 3}, default: :authorized

  enumerize :payment_mode, in: { cb: 'cb', sepa: 'sepa', none: 'none' }, default: :none, scope: true, predicates: true

  # Users who have a running Subscription.
  scope :active, -> { joins(:subscriptions).merge(Subscription.active) }

  # Users who have no running Subscriptions.
  scope :inactive, -> { where("(SELECT COUNT(*) FROM subscriptions WHERE (state = 'running' OR state = 'temporarily_suspended') AND user_id = users.id) = 0") }

  # Users who have no Visit in progress.
  scope :not_visiting, -> { where("(SELECT COUNT(*) FROM visits WHERE ended_at IS NULL AND user_id=users.id) = 0") }

  before_save :strip_postal_code

  # Public: Fetch all users who have unpayed invoices.
  #
  # Returns a Array of user or [].
  def self.red_list
    with_role(:user)
    .active
    .joins(:invoices)
    .where('invoices.state IN (?)', [:pending_payment_retry])
    .uniq
  end

  # Public: Check if user has one invoice that have the state :pending_payment_retry
  #
  # Returns a boolean true or false
  def is_not_in_red_list?
    !invoices.any?(&:pending_payment_retry?)
  end

  # Public: Check if user has one subscription that have the state :temporarily_suspended
  #
  # Returns a boolean true or false
  def is_not_temporarily_suspended?
    !subscriptions.any?(&:temporarily_suspended?)
  end

  # Public: Fetch the planning location.
  #
  # Returns a string 'moliere' or 'maillot' or 'amelot'.
  def planning_location
    if lesson_bookings.try(&:last).present?
      lesson_bookings.last.lesson.location
    else
      subscriptions.try(&:last).try(&:locations).try{ |l| l.reject(&:empty?) }.try(&:first)
    end
  end

  def available_locations
    subscriptions.try(&:last).try(&:locations).try{ |l| l.reject(&:empty?) }
  end

  # Public: Fetch the current visit in progress.
  #
  # Returns a Visit record or nil.
  def current_visit
    visits.in_progress.order(:started_at).last
  end

  # Public: Check if the User has LessonBooking records for
  # upcoming lessons.
  #
  # Returns a Boolean.
  def has_upcoming_lessons?
    lesson_bookings.upcoming.exists?
  end

  # Public: Check if the User has access to the local with his card.
  #
  # Returns a Boolean.
  def card_access_authorized?
    card_admin_access? || (card_access.authorized? || card_access.forced_authorized?)
  end

  # Public: Check if the User has admin access for his linked card.
  #
  # Returns a Boolean.
  def card_admin_access?
    ['admin', 'staff'].include?(role)
  end

  # Public: Determines if the User has a running Subscription.
  #
  # Returns a Boolean.
  def active?
    subscriptions.any?(&:running?)
  end

  # Public: Determines if the User has a temporarily suspended Subscription.
  #
  # Returns a Boolean.
  def has_temporarily_suspended_subscription?
    subscriptions.any?(&:temporarily_suspended?)
  end

  # Public: Check if the user currently has some declined payments
  #
  # Returns a Boolean
  def has_late_payments?
    invoices_with_states(%i(pending_payment pending_payment_retry)).any? { |invoice| invoice.payments.any? }
  end

  # Public: Check if the user currently has some unpaid invoices with payments declined more than once
  #
  # Returns a Boolean
  def has_late_payments_retry?
    invoices_with_states(%i(pending_payment pending_payment_retry)).map{ |invoice| invoice.payments.with_state(:declined) }.flatten.size >= 2
  end

  # Public: Determines if the user's subscription has a commitment period.
  #
  # Returns a Boolean.
  def committed?
    subscriptions.any? do |subscription|
      subscription.commitment_period > 0 && subscription.running?
    end
  end

  # Public: Check if the user's payments are up to date.
  #
  # Returns a Boolean.
  def payments_up_to_date?
    invoices.with_state(:pending_payment_retry).none?
  end

  # Public: Generic method to check invoices by state, which have payments.
  # See has_late_payments? and has_late_payments_retry? for details.
  #
  # Returns Boolean
  def invoices_with_states(states)
    invoices.with_states(states).includes(:payments)
  end

  # Public: Check if the user has notification for a type of notification
  #
  # Returns a Boolean
  def has_notification_for?(source_type, source_id)
    notifications.where(sourceable_id: source_id, sourceable_type: source_type).first.present?
  end

  # Public: Check if the user currently has some payment means
  #
  # Returns a Boolean
  def has_payment_means?
    credit_cards.any? || mandates.ready.any?
  end

  # Public: Update the force_access_to_planning boolean with the state param
  #
  # Returns a Boolean
  def update_access_to_planning!(state)
    update_attributes!(force_access_to_planning: state)
  end

  # Public: Check if the user currently has a sepa solution method active
  #
  # Returns a Boolean
  def has_payment_solution_sepa?
    mandates.ready.last.present?
  end

  # Public: Check if the user currently has a credit card solution method active
  #
  # Returns a Boolean
  def has_payment_solution_cb?
    current_credit_card.present?
  end

  # Public: Check if the user currently has a solution method active
  #
  # Returns a Boolean
  def has_payment_solution_active?
    has_payment_solution_sepa? || has_payment_solution_cb?
  end

  # Public: Check if the user currently has access to the planning
  #
  # Returns a Boolean
  def has_access_to_planning?
    (force_access_to_planning? || (has_payment_solution_sepa? && !has_late_payments_retry?)) && !forbid_access_to_planning?
  end

  # Public: return the phone number in +33 format
  #
  # Returns a string
  def slimpay_formated_phone
    return if phone.blank?
    return phone if phone[0] == '+'
    return "+#{phone}" if phone[0] == '3' && phone[1] == '3'
    "+33#{phone[1..-1]}"
  end

  # Public: Determine if the access_card need to be forbiden (from task user:access_forbidden)
  #
  # Returns a boolean
  def invalid_access_card?
    subscriptions.last.nil? || subscriptions.last.end_at.nil? || subscriptions.last.end_at < (DateTime.now - 1.month)
  end

  # Public: Determine if the requirements are filled to place an order
  #
  # Returns a boolean
  def can_order?
    has_payment_solution_active? && !invalid_access_card?
  end

  def deactivate(t = Time.current)
    ActiveRecord::Base.transaction do
      invoices.with_state([:pending_payment, :pending_payment_retry, :sepa_waiting, :open]).each do |invoice|
        invoice.state = "canceled"
        invoice.canceled_at = DateTime.now
        invoice.save(validate: false)
      end
      update_attribute(:deactivated_at, t)
    end
  end

  def activate
    update_attribute(:deactivated_at, nil)
  end

  def deactivated?
    self.send(:deactivated_at).present?
  end

  private

  def strip_postal_code
    self.postal_code = postal_code.strip if postal_code.present?
  end

  def uniq_planning_access_bypass
    return true if force_access_to_planning == false || forbid_access_to_planning == false
    errors.add :planning_access_bypass, 'should be uniq'
  end

  # Internal: Standardize the email attribute
  # to allow for better duplicate checks.
  #
  # Returns nothing.
  def format_email
    return if email.blank?
    self.email = email.strip.downcase
  end

  # Internal: Validate that the password attribute
  # matches complexity checks.
  #
  # Returns nothing.
  def password_matches_format
    return if password.blank?
    unless password =~ /\d/ && password =~ /[a-zA-Z]/ && password.length >= 8
      errors.add(:password, :password_format)
    end
  end
end
