ENV.each { |k, v| env(k, v) }

require "tzinfo"

def local(time)
  TZInfo::Timezone.get('Europe/Paris').local_to_utc(Time.parse(time)).strftime("%H:%M")
end

set :chronic_options, hours24: true
set :output, "log/cron_log.log"

if environment == "production" || environment == "staging"
  every 1.day, at: local('00:00') do
    runner 'Visits::SweepJob.perform_later' # rake 'visits:sweep'
  end

  every 1.day, at: local('00:04') do
    runner 'Lessons::CreateJob.perform_later' # rake 'lessons:create'
  end

  every 1.day, at: local('00:08') do
    runner 'Subscriptions::CheckJob.perform_later' # rake 'subscriptions:check'
  end

  every 1.day, at: local('00:12') do
    runner 'Users::CheckJob.perform_later' # rake 'users:check'
  end

  every 1.day, at: local('00:18') do
    #runner 'Slimpay::RefreshMandatesJob.perform_later' # rake 'slimpay:refresh_mandates'
  end

  every 30.minutes do
    #runner 'Slimpay::ReportPaymentErrorsJob.perform_later' # rake 'slimpay:report_payment_errors'
  end

  every 1.day, at: local('00:45') do
    #runner 'Slimpay::AcceptSepaPaymentsJob.perform_later' # rake 'slimpay:accept_sepa_payments'
  end

  every 1.hour do
    runner 'NotificationSchedules::StartJob.perform_later' # rake 'notification_scheduler:start'
  end

  every 1.hour do
    runner 'NotificationSchedules::SuspendedSubscriptionJob.perform_later' # rake 'subscriptions:suspended_subscription_scheduler'
  end

  every 1.day, at: local('01:20') do
    #runner 'Invoices::ReplaceDeferredJob.perform_later' # rake 'invoices:replace_deferred'
  end

  every 1.day, at: local('01:50') do
    runner 'Users::UpdateGroupsJob.perform_later' # rake 'users:update_groups'
  end

  every 1.day, at: local('03:00') do
    #runner 'Invoices::ChargesPendingDeferredJob.perform_later' # rake 'invoices:charge_pending_deferred'
  end

  every 1.day, at: local('03:30') do
  #runner 'Invoices::CheckJob.perform_later' # rake 'invoices:check' # rake 'invoices:check_validation'
  end

  every 1.day, at: local('03:45') do
    #runner 'Subscriptions::RestartsJob.perform_later' # rake 'subscriptions:restart' # rake 'subscriptions:restart_mailer'
  end

  every 1.day, at: local('04:30') do
    runner 'Users::AccessForbiddenJob.perform_later' # rake 'users:access_forbidden'
  end

  every 1.week do
    rake 'pg:backup'
  end

  every 1.month do
    runner 'Invoices::CleanExportsJob.perform_later' # rake 'invoices:clean_exports'
  end
end
