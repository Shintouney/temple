class ForceAccessToPlanningToTrueForUsers < ActiveRecord::Migration
  def change
  	User.update_all(force_access_to_planning: true)
  end
end
