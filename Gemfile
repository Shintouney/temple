source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.3.7'

gem 'nokogiri'
gem 'rails', '< 5'
gem 'bootsnap', require: false

gem 'pg', '0.19'
gem 'puma', '< 4'

gem 'haml-rails'
gem 'sass-rails', '< 6'
gem 'font-awesome-sass'
gem 'uglifier'
gem 'coffee-rails', '~> 4.0.0'
gem 'therubyracer', platforms: :ruby
gem 'non-stupid-digest-assets'
gem 'high_voltage', '~> 3.1'
gem 'modernizr-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'

gem 'wicked_pdf'
gem 'csv_shaper'

gem 'config'

gem 'draper'
gem 'simple_form', '~> 3.5.1'
gem 'active_link_to'

gem 'sorcery', '~> 0.13.0'
gem 'email_validator'
gem 'enumerize', '~> 0.8.0'
gem 'aasm'
gem 'paperclip'
gem 'acts_as_list'
gem 'gibberish', '~> 1.4.0'
gem 'tod', '< 2'
gem 'social-share-button'

gem 'httparty'
gem 'net-sftp'

gem 'sentry-raven'
gem 'pry-rails'

gem 'active_utils',  '2.0.2'
gem 'activemerchant', '1.73.0'
gem 'activemerchant_paybox_direct_plus', '~> 0.2'

gem 'whenever', :require => false
gem 'wkhtmltopdf-binary'

gem 'redis'
gem 'redis-namespace'
gem 'sidekiq'
gem 'sidekiq-failures'
#gem 'sinatra', '>= 1.3.0', require: false

gem 'schema_plus'
gem 'icalendar'
gem 'slimpay', github: 'navidemad/slimpay', branch: 'develop'
gem 'kaminari', '~> 0.16'
gem 'country_select', '~> 1.3.1'

gem 'pagy'
gem 'lograge'
gem 'awesome_print'

#asset "enquire", "2.1.6"
gem 'rails-enquirejs', '~> 2.1', '>= 2.1.2'

#asset "bootstrap", "latest"
gem 'bootstrap-sass', '~> 3.3', '>= 3.3.6'

#asset "bootstrap-toggle", "2.2.2"
gem 'bootstrap-toggle-rails'

#asset "fullcalendar", "3.10.0"
gem 'fullcalendar'

#asset "moment", "2.24.0"
gem 'momentjs-rails'

#asset "datatables.net", "1.10.16"
gem 'jquery-datatables'

#asset "jqueryui-timepicker-addon", "1.6.3"
gem 'jquery-timepicker-addon-rails'

#asset "mixitup", "2.1.11"
gem 'mixitup_rails'

#asset "matchHeight", "0.7.2"
gem 'jquery-matchheight-rails'

#asset "webui-popover",  "1.2.18"
gem 'webui-popover-rails'

#asset "select2", "4.0.5"
gem 'select2-rails'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-local-precompile', '~> 1.2.0', require: false
  gem 'net-ssh', '< 5'
  gem 'guard'
  gem 'guard-rspec', require: false
  gem 'guard-bundler', require: false
  gem 'quiet_assets'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'active_record_query_trace'
end

group :development, :test do
  gem 'byebug'
  gem 'transactional_capybara'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'rspec-core'
  gem 'rspec-expectations'
  gem 'rspec-mocks'
  gem 'rspec-support'
  gem 'fivemat'
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'factory_bot_rails', '< 5'
  gem 'did_you_mean', '~> 0.10'
  # net-ssh 4.2 requires the gems below to support ed25519 keys
  # for deploying via capistrano
  # more info at https://github.com/net-ssh/net-ssh/issues/478
  gem "bcrypt_pbkdf", ">= 1.0", "< 2.0", require: false
  gem "rbnacl", ">= 3.2", "< 5.0", require: false
  gem "rbnacl-libsodium", require: false
end

group :test do
  gem 'redis_test'
  gem 'database_cleaner'
  gem 'capybara-screenshot'
  gem 'capybara-webkit'
  gem 'vcr', '~> 4.0'
  gem 'webmock'
  gem 'timecop'
  gem 'simplecov', require: false
  gem 'cane', require: false
  gem 'flog', require: false
  gem 'rubocop', '~> 0.26.0', require: false
end
