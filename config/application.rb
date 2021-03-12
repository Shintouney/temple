require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Temple
  class Application < Rails::Application
    config.autoload_paths << Rails.root.join('app', 'decorators', 'concerns')
    config.autoload_paths << Rails.root.join('app', 'services', 'concerns')
    config.time_zone = "Paris"
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '*', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :fr
    config.i18n.available_locales = %i(fr)
    config.i18n.enforce_available_locales = false
    config.i18n.fallbacks = %i(fr)
    config.assets.precompile << /\.(?:svg|eot|woff|woff2|ttf)\Z/  
    config.generators do |g|
      g.assets false
      g.helper false
      g.view_specs false
      g.controller_specs false
    end
    config.active_record.raise_in_transactional_callbacks = true
    config.active_job.queue_adapter = :sidekiq
    config.exceptions_app = self.routes
    ::Sass::Script::Number.precision = [8, ::Sass::Script::Number.precision].max
  end
end
