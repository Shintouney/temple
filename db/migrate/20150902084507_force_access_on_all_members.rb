class ForceAccessOnAllMembers < ActiveRecord::Migration
  def change
    User.where("users.created_at < ?", Date.parse('15/08/2015')).update_all(force_access_to_planning: true)
  end
end
