class AddLocationToVisit < ActiveRecord::Migration
  def change
    add_column :visits, :location, :string

    Visit.all.each { |visit| visit.update_attribute(:location, 'moliere') }
  end
end
