# We have activemerchant locked at 1.42.6 and had to do this to get our older legacy app working again.
# Confirmed this monkey patch worked.
# I added to rails initializers with a comment linking the developer announcement.
# Longer term we should update the certs, not just that one URL.
module ActiveMerchant
  module Billing
    class AuthorizeNetGateway
      self.live_url = 'https://api2.authorize.net/xml/v1/request.api'
    end
  end
end
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
