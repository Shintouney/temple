Slimpay.configure do |config|
  config.client_id = Settings.slimpay.client_id
  config.client_secret = Settings.slimpay.client_secret
  config.creditor_reference = Settings.slimpay.creditor_reference
  config.sandbox = Settings.slimpay.sandbox
  config.notify_url = Settings.slimpay.notify_url
  config.return_url = Settings.slimpay.return_url
  config.username = Settings.slimpay.username
  config.password = Settings.slimpay.password
end
