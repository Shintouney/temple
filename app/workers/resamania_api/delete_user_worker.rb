module ResamaniaApi
  class DeleteUserWorker
    include Sidekiq::Worker

    def perform(user_id)
      ResamaniaApi::DeleteUser.new(user_id).execute
    end
  end
end
