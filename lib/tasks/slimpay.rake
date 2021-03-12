namespace :slimpay do
  desc 'Setup Slimpay Return URL'
  task setup: :environment do
    app = Slimpay::App.new
    app.change_urls(returnUrl: Settings.slimpay.return_url, notifyUrl: Settings.slimpay.notify_url)
  end

  desc 'Refresh mandate for eventual revokations'
  task refresh_mandates: :environment do
    Mandate.ready.each(&:refresh)
  end

  desc 'Mark unchanged sepa_payments as paid'
  task accept_sepa_payments: :environment do
    Payment.with_state(:waiting_slimpay_confirmation).where('payments.created_at < ?', Date.today.advance(days: -6)).each do |payment|
      payment.accept!
      payment.invoices.first.accept_payment!
    end
  end

  desc "Retrieve Slimpay's sepa payments error reports"
  task report_payment_errors: :environment do
    Slimpay::SynchronizeErrorReporting.new.execute
  end
end
