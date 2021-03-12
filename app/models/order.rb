class Order < ActiveRecord::Base
  include TotalPricesCalculations

  attr_accessor :direct_payment

  belongs_to :user
  belongs_to :invoice
  has_many :order_items, -> { order(:created_at) }, dependent: :destroy

  validates :user, :invoice, presence: true

  accepts_nested_attributes_for :order_items, reject_if: :all_blank

  scope :from_current_month, -> { where("created_at >= ?", Date.today.beginning_of_month) }
  scope :sorted, -> { order(created_at: :desc) }

  before_destroy :validate_destroyable_only_with_open_invoice

  public :computed_total_price_ati, :computed_total_price_te

  private

  def validate_destroyable_only_with_open_invoice
    unless invoice.open?
      errors.add(:base, :can_not_destroy_without_open_invoice)
      false
    end
  end
end
