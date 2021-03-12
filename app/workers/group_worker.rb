# encoding: UTF-8
class GroupWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(group_id)
    group = Group.find group_id
    group.users = User::Search.new(group.attributes).execute
    group.save!
  end
end
