class Users::UpdateGroupsJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    ::Group.select(:id).pluck(:id).each do |group_id|
      ::Users::UpdateGroupJob.perform_later(group_id)
    end
  end
end
