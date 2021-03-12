# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:authorization, :password, :passwd, :secret, :number, :verification_value, :password_confirmation, :credit_card]
