namespace :invoices do
  desc 'Check Invoices and Payments inconsistencies'
  task check: :environment do
    all_invoices = Invoice.all
    paid_invoices = Invoice.with_state(:paid)
    pending_invoices = Invoice.with_state(:pending_payment_retry)
    newly_created_invoices = Invoice.where(end_at: Date.today - 1.day)

    puts "Checking #{ all_invoices.size } invoices for double payments"
    double_paid_invoices = check_invoices_for_double_payments(all_invoices)
    display_results(double_paid_invoices)

    puts "\n\rChecking #{ paid_invoices.size } paid invoices for unmatched payments (0 accepted)..."
    unmatched_paid_invoices = check_paid_invoices(paid_invoices)
    display_results(unmatched_paid_invoices)

    puts "\n\rChecking #{ pending_invoices.size } pending for retry invoices..."
    unmatched_retry_invoices = check_pending_invoices(pending_invoices)
    display_results(unmatched_retry_invoices)

    check_payments

    puts "\n\rChecking invoices created today : Search for doublon, email will be send if needed."
    check_newly_created_invoices(newly_created_invoices)
  end

  desc "Check due invoices are valid"
  task check_validation: :environment do
    puts "Checking #{ Invoice.due.size } invoice"
    invoice_ids = check_current_invoices_valid
    display_results(invoice_ids)
    AdminMailer.invalid_invoices(invoice_ids).deliver_later if invoice_ids.any?
  end

  def check_payments
    payments = Payment.all
    puts "\n\rChecking #{ payments.size } payments to belong to one and only invoice..."
    unmatched_payments = check_payments_invoice(payments)
    display_results(unmatched_payments)
  end

  private

  def check_current_invoices_valid
    invoice_ids = {}
    Invoice.with_state([:open, :pending_payment, :pending_payment_retry]).each do |invoice|
      next if invoice.valid? && invoice.start_at.present? &&
                                invoice.end_at.present? && invoice.total_price_ati.present? && invoice.user_id.present?

      invoice_ids[invoice.id] = "Invalid invoice n°#{invoice.id}: #{invoice.errors.full_messages.join(',')}"
    end
    invoice_ids
  end

  def check_newly_created_invoices(newly_created_invoices)
    newly_created_invoices = newly_created_invoices_filtred(newly_created_invoices)
    user_ids = newly_created_invoices.map{ |e| e.user.id }
    suspicious_user_ids = user_ids.select { |e| user_ids.count(e) > 1 }.uniq
    temple_ghosts_emails = [Settings.user.cash.email, Settings.user.cb.email, Settings.user.cheque.email, Settings.user.compensation.email]
    ghosts_ids = User.where(email: temple_ghosts_emails).pluck(:id)
    suspicious_user_ids.delete_if{ |user_id| ghosts_ids.include?(user_id) }
    AdminMailer.suspicious_invoices(suspicious_user_ids).deliver_later if suspicious_user_ids.present?
  end

  def newly_created_invoices_filtred(newly_created_invoices)
    newly_created_invoices = newly_created_invoices.select do |e|
      e.order_items.detect { |o| o.product_type == "SubscriptionPlan" }.present?
    end
  end

  # Paid invoices without an accepted payment.
  def check_paid_invoices(invoices)
    unmatched_paid_invoices = {}
    invoices.each do |invoice|
      unmatched_paid_invoices["Invoice #{invoice.id}"] = 'NO PAYMENTS' if invoice.payments.blank?
      payment = invoice.payments.last
      next if payment.state == 'accepted'
      next if payment.paybox_transaction.present?
      next if User::TEMPLE_GHOSTS.include?(payment.user.email)
      unmatched_paid_invoices["Invoice #{invoice.id}"] = "Inconsistent Payment id:#{payment.id}"
    end
    unmatched_paid_invoices
  end

  def check_pending_invoices(invoices)
    unmatched_retry_invoices = {}
    invoices.each do |invoice|
      invoice.payments.each do |payment|
        unmatched_retry_invoices[invoice.id] = "Inconsistent Payment #{payment.id}" unless payment.state == 'declined'
      end
    end
    unmatched_retry_invoices
  end

  def check_payments_invoice(payments)
    unmatched_payments = {}
    payments.each do |payment|
      next if payment.invoices.size == 1
      unmatched_payments[payment.id] = "Payment with several invoices #{ payment.invoices.pluck(:id) }"
    end
    unmatched_payments
  end

  def check_invoices_for_double_payments(invoices)
    invoices_with_double_payments = {}
    invoices.each do |invoice|
      next if check_double_payments(invoice) <= 1
      invoices_with_double_payments[invoice.id] = "Double payment found."
    end
    AdminMailer.invoices_with_double_payments(invoices_with_double_payments.keys).deliver_later if invoices_with_double_payments.any?
    invoices_with_double_payments
  end

  def check_double_payments(invoice)
    paid_count = 0
    invoice.payments.each do |payment|
      next unless payment.accepted?
      paid_count += 1
    end
    paid_count
  end
end
