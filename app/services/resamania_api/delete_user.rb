module ResamaniaApi
  class DeleteUser < Base

    attr_reader :user_id

    def initialize(user_id)
      @user_id = user_id
    end

    private

    def request
      HTTParty.delete(user_url, options)
    end

    def user_url
      "#{Settings.api.resamania.user_url}/#{user_id}"
    end
  end
end
