class AdminMailer < ActionMailer::Base
  default Settings.mailer.admin.to_hash
  layout "mail"

  def monthly_subscription_payment_retry_failed(user_id)
    @user = User.find(user_id).decorate
    mail
  end

  def error(name, error_body)
    @error_name = name
    @details = error_body
    mail 'Content-Transfer-Encoding' => 'quoted-printable'
  end

  def suspicious_invoices(user_ids)
    @users = user_ids.map { |user_id| User.find(user_id) }
    mail to: "developers@tsc.digital"
  end

  def sepa_payment_rejected(payment_id)
    @payment = Payment.find(payment_id)
    mail
  end

  def invoice_charge_error(invoice_ids)
    @invoice_ids = invoice_ids
    mail to: "developers@tsc.digital"
  end

  def invalid_invoices(invoice_ids)
    @invoices = invoice_ids.map { |invoice_id| Invoice.find(invoice_id) }
    mail to: "developers@tsc.digital"
  end

  def invalid_users(users_hash, reason)
    @users_hash = users_hash
    @users = users_hash.keys.map { |user_id| User.find(user_id) }
    @text = I18n.t(:text, scope: [:admin_mailer, reason])
    mail to: "developers@tsc.digital", subject: subject_for(reason)
  end

  def invoices_with_double_payments(invoice_ids)
    @invoices = invoice_ids.map { |invoice_id| Invoice.find(invoice_id) }
    mail to: "developers@tsc.digital"
  end

  def suspended_subscription(user)
    @user = user
    mail to: "developers@tsc.digital"
  end

  def restart_subscription_fail(user_id)
    @user = User.find(user_id)
    mail to: "developers@tsc.digital"
  end

  def unsubscribe_request_notification(unsubscribe_request_id)
    @unsubscribe_request = UnsubscribeRequest.find(unsubscribe_request_id)
    mail to: "service-membres@temple-nobleart.fr"
  end

  def sponsoring_request_notification(sponsoring_request_id)
    @sponsoring_request = SponsoringRequest.find(sponsoring_request_id)
    mail to: "contact@temple-nobleart.fr"
  end

  def lesson_request_notification(lesson_request_id)
    @lesson_request = LessonRequest.find(lesson_request_id)
    mail to: "contact@temple-nobleart.fr"
  end

  private

  def subject_for(reason)
    case reason
    when :payment_mode
      I18n.t(:subject, scope: [:admin_mailer, :payment_mode])
    when :pending_subscription
      I18n.t(:subject, scope: [:admin_mailer, :pending_subscription])
    end
  end
end
