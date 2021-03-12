class Slimpay::ReportPaymentErrorsJob < ActiveJob::Base
  queue_as :default

  # Retrieve Slimpay's sepa payments error reports
  def perform
    ::Slimpay::SynchronizeErrorReporting.new.execute
  end
end
