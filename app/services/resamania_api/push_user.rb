module ResamaniaApi
  class PushUser < Base

    attr_reader :user

    def initialize(user)
      @user = user
    end

    private

    def request
      HTTParty.post(Settings.api.resamania.user_url, options)
    end

    def options
      super.merge(body: payload.to_json)
    end

    def payload
      {
        id: user.id,
        mail: user.email,
        authorized: user.card_access_authorized?,
        card_reference: user.card_reference,
        admin: user.card_admin_access?,
        locations: user_locations
      }
    end

    def user_locations
      if user.user?
        user.subscriptions.last.locations.map { |l| l == "moliere" ? 1 : l == "maillot" ? 2 : 3 }
      else
        [1, 2, 3]
      end
    end
  end
end
