require 'raven'
Raven.configure do |config|
  #config.environments = %w[ production staging ]
  config.environments = %w[]
  config.current_environment = Rails.env.to_s
  config.dsn = 'https://d9e5b6e9fc5c4b08b48003aeeab44652@sentry.io/17050'
  config.excluded_exceptions = Raven::Configuration::IGNORE_DEFAULT | %w[ ActionView::TemplateError ActiveRecord::RecordNotFound AbstractController::ActionNotFound ActionController::RoutingError ActionController::UnknownFormat ]
  config.inspect_exception_causes_for_exclusion = true
  config.ssl_verification = false
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.async = lambda { |event| SentryJob.perform_later(event) unless event.nil? }
  config.timeout = 10
  config.open_timeout = 10
end
