require 'active_utils/common/validateable'

class ActiveMerchant::Validateable::Errors
  def add(field, error)
    self[field] << I18n.t(:"attributes.#{field}.#{error}",
                          scope: 'activemerchant.errors',
                          default: [:"messages.#{error}", error])
  end
end

class ActiveMerchant::Billing::CreditCard
  attr_accessor :message_from_paybox
  def valid?
    super
    unless self.verification_value.present?
      errors.add(:cvv, :missing)
    end
    self.verification_value.present? &&  self.number.present? && self.month.present? && self.year.present? && self.brand.present?
  end
end
