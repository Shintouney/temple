require 'httparty'

module ResamaniaApi
  class Base

    def execute
      response = request

      return true if response.code.to_s =~ /20./
      raise "Response code for #{self.class.name}#execute was #{response.code}."
    end

    private

    def options
      base_options = {
        headers: {
          "X-Auth" => Settings.api.resamania.auth_token,
          "Content-Type" => 'application/json'
        }
      }

      if Settings.api.resamania.digest_auth
        base_options.merge(digest_auth: Settings.api.resamania.digest_auth.to_hash)
      else
        base_options
      end
    end
  end
end
