if Rails.env.production?
  SUPPORTED_CARDTYPES = [:visa, :master]
else
  SUPPORTED_CARDTYPES = [:visa, :master, :bogus]

  ActiveMerchant::Billing::Base.mode = :test
end
