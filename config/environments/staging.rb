# Just use the production settings
require File.expand_path('../production.rb', __FILE__)

Rails.application.configure do
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.perform_caching = false
  config.cache_store = :null_store
  config.action_mailer.asset_host = "https://staging-membres.temple-nobleart.fr"
  config.action_mailer.default_url_options = {
    host: "staging-membres.temple-nobleart.fr",
    protocol: 'https'
  }
  config.action_mailer.smtp_settings = {
    :user_name => '20952bfc139ae3574',
    :password => '110cf2475aa4d2',
    :address => 'smtp.mailtrap.io',
    :domain => 'smtp.mailtrap.io',
    :port => '2525',
    :authentication => :cram_md5
  }
end
