module ResamaniaApi
  class PushUserWorker
    include Sidekiq::Worker

    def perform(user_id)
      user = User.find(user_id)

      ResamaniaApi::PushUser.new(user).execute
    end
  end
end
