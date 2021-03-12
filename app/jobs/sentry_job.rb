class SentryJob < ActiveJob::Base
  queue_as :sentry

  # rescue_from(Raven::Error) do |exception|
  #   retry_job wait: 1.day, queue: :sentry     
  # end

  def perform(event)
    #::Raven.send_event(event)
  end
end
