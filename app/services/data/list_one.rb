class Data
  class ListOne

    def initialize(user:)
      @user = user
      @date = Date.new(2020, 07, 31)
    end

    def call
      @sub = @user.subscriptions.where(state: "temporarily_suspended")
      @sub.first.restart_date = @date
      @sub.first.save
      @sub
    end
  end
end
