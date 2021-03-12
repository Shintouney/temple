class InvoiceDecorator < ApplicationDecorator
  delegate_all

  decorates_association :order_items

  # Public: The reference for the Payment.
  #
  # Returns a String.
  def reference
    object.id.to_s
  end

  # Public: The reference for the credit note.
  #
  # Returns a String.
  def reference_credit_note
    object.credit_note_ref.to_s
  end

  # Public: The translated state.
  #
  # Returns a String.
  def state
    object.human_state_name
  end

  # Public: a CSS label class representing the object state.
  #
  # Returns a String.
  def state_label_class
    if pending_payment?
      "label-warning"
    elsif pending_payment_retry?
      "label-danger"
    elsif paid? || payment_not_needed? || sepa_waiting?
      "label-success"
    else
      "label-default"
    end
  end

  # Public: The formatted name of the Payment user.
  #
  # Returns a String.
  def user_full_name
    return object.billing_name if object.billing_name.present?
    "#{user_firstname} #{user_lastname}"
  end

  # Public: The accepted Payment linked to the Invoice.
  #
  # Returns a decorated Payment record or nil.
  def accepted_payment
    payments.last.try(:decorate)
  end

  # Public: The credit note date attribute formatted as a String.
  #
  # Returns the localized String.
  def credit_note_end_at
    I18n.l(object.refunded_at.to_date)
  end

  # Public: The end_at attribute formatted as a String.
  #
  # Returns the localized String.
  def end_at
    I18n.l(object.end_at)
  end

  # Public: The human-formatted total_price_ati.
  #
  # Returns a String.
  def total_price_ati
    if object.open?
      I18n.t('admin.invoices.index.total_price_ati_will_be_computed')
    else
      formatted_price(object.total_price_ati)
    end
  end

  # Public: The human-formatted sum of every orders total_price_te.
  #
  # Returns a String.
  def total_price_te
    if object.open?
      I18n.t('admin.invoices.index.total_price_ati_will_be_computed')
    else
      formatted_price(object.computed_total_price_te)
    end
  end

  # Public: Generates a Hash representing the taxes amounts,
  # with the keys as the taxes rates formatted as a localized String
  # and the values as the localized total price for the tax rate.
  #
  # Returns a Hash.
  def taxes_amounts
    total_prices_te_by_taxes_rates.map do |taxes_rate, price_without_taxes|
      tax_amount = price_without_taxes.to_f * (taxes_rate / 100)

      {formatted_taxes_rate(taxes_rate) => formatted_price(tax_amount)}
    end.reduce({}, :merge)
  end

  # Public: Creates a Hash with Arrays of OrderItems, categorized by ArticleCategory.
  #
  # The Hash keys are ArticleCategory ids.
  # The Hash values are Arrays of OrderItems.
  #
  # Returns a Hash.
  def order_items_by_article_categories
    object.order_items.includes(:product).where(product_type: 'Article').reduce({}) do |hash, order_item|
      hash[order_item.product_category_name] ||= []
      hash[order_item.product_category_name].push(order_item)
      hash
    end
  end

  # Public: Creates a Hash with BigDecimals, categorized by ArticleCategory.
  #
  # The Hash keys are ArticleCategory ids.
  # The Hash values are the total price TE of the OrderItems, as BigDecimals.
  #
  # Returns a Hash.
  def prices_te_by_articles_categories
    order_items_by_article_categories.reduce({}) do |hash, order_items_by_article_category|
      hash.merge(
        order_items_by_article_category.first =>
          formatted_price(order_items_by_article_category.last.sum(&:product_price_te))
      )
    end
  end

  # Public: Creates a Hash with Arrays of OrderItems, categorized by ArticleCategory and taxes rate.
  #
  # The Hash keys are ArticleCategory ids.
  # The Hash values are Arrays of OrderItems.
  #
  # Returns a Hash.
  def order_items_by_article_categories_and_taxes
    object.order_items.includes(:product).where(product_type: 'Article').reduce({}) do |hash, order_item|
      hash["#{order_item.product_category_name}_#{order_item.product_taxes_rate}"] ||= []
      hash["#{order_item.product_category_name}_#{order_item.product_taxes_rate}"].push(order_item)
      hash
    end
  end

  # Public: Creates a Hash with BigDecimals, categorized by ArticleCategory and taxes rate.
  #
  # The Hash keys are ArticleCategory ids.
  # The Hash values are the total price TE of the OrderItems, as BigDecimals.
  #
  # Returns a Hash.
  def prices_te_by_articles_categories_and_taxes
    order_items_by_article_categories_and_taxes.reduce({}) do |hash, order_items_by_article_category|
      hash.merge(
        order_items_by_article_category.first =>
          formatted_price(order_items_by_article_category.last.sum(&:product_price_te))
      )
    end
  end

  def subscription_plan_order_item_price_te
    order_item = object.order_items.includes(:product).where(product_type: 'SubscriptionPlan').first

    order_item.nil? ? nil : formatted_price(order_item.product_price_te)
  end

  def temple_location
    _order = object.orders.includes(:order_items).first
    if _order.present?
      return _order.location if _order.location.present?
      _order_item = _order.order_items.includes(:product).first
      if _order_item.present? && _order_item.product.present? && _order_item.product.respond_to?(:locations) && _order_item.product.locations.present?
        return order_items.first.product.locations.reject(&:empty?).join("/").presence
      end
    end
    return nil
  end

  # Public: A localized name to identify a PDF export
  # of the record.
  #
  # Returns a String.
  def pdf_file_name
    "#{Payment.model_name.human}_#{I18n.l(object.created_at, format: '%Y%m%d%-k%M')}"
  end

  # Public: Returns the product name of the given order_item.
  # If the product is a SubscriptionPlan, the subscription_period_start_at
  # and subscription_period_end_at field values are added to the string.
  #
  # order_item - The OrderItem
  #
  # Returns a String.
  def order_item_product_name(order_item)
    if order_item.product.is_a?(SubscriptionPlan) && object.deferred?
      I18n.t('invoice.decorator.subscription_period',
        product_name: order_item.product_name,
        start_date: I18n.l(object.subscription_period_start_at),
        end_date: I18n.l(object.subscription_period_end_at))
    else
      order_item.product_name
    end
  end

  # Public: The paybox transaction number is composed by
  # the paybox call number + the paybox reference. Format the string to split those number
  #
  # Returns a String.
  def paybox_transaction_number
    return unless accepted_payment.present? && accepted_payment.paybox_transaction.present?
    "Num Appel : #{accepted_payment.paybox_transaction[0..9]} | Ref Paybox : #{accepted_payment.paybox_transaction[10..19]}"
  end
end
