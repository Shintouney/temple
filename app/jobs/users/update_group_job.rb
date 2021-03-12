class Users::UpdateGroupJob < ActiveJob::Base
  queue_as :default

  def perform(group_id)
    group = ::Group.find(group_id)
    group.users = ::User::Search.new(group.attributes).execute
    group.save!
  end
end
