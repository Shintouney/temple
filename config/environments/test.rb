Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true
  config.cache_store = :memory_store

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = true

  # Configure static asset server for tests with Cache-Control for performance.
  config.serve_static_files  = true
  config.static_cache_control = "public, max-age=3600"

  config.assets.raise_production_errors = true

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false
  config.action_controller.action_on_unpermitted_parameters = :raise

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  config.i18n.exception_handler = :raise_exception

  config.action_mailer.asset_host = "http://0.0.0.0:4343"
  config.action_mailer.default_url_options = { host: "0.0.0.0:4343" }
  Paperclip::Attachment.default_options[:path] = "#{Rails.root}/spec/support/test_files/:class/:id_partition/:style.:extension"

  require 'rack_no_animations'
  config.middleware.use Rack::NoAnimations

  # https://github.com/jnicklas/capybara#setup
  config.allow_concurrency = false
end
