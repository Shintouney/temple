class AddFiltersToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :filter_between_age, :string
    add_column :groups, :filter_gender, :string
    add_column :groups, :filter_postal_code, :string
    add_column :groups, :filter_with_subscription, :string
    add_column :groups, :filter_created_since, :string
    add_column :groups, :filter_usual_room, :string
    add_column :groups, :filter_usual_activity, :string
    add_column :groups, :filter_frequencies, :string
    add_column :groups, :filter_last_booking_dates, :string
    add_column :groups, :filter_last_visite_dates, :string
    add_column :groups, :filter_last_article, :string
  end
end
