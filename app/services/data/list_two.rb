class Data
  class ListTwo

    def initialize(user:)
      @user = user
      @date_begin = Date.new(2020, "08".to_i, 01)
      @date_end = Date.new(2020, "08".to_i, 31)
    end

    def call
      @sub = @user.subscriptions.where(state: "temporarily_suspended")
      @sub.first.state = "running"
      @sub.first.suspended_at = @date_begin
      @sub.first.restart_date = @date_end
      @sub.first.save
    end
  end
end
