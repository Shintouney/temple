module CSVExporter
  class Subscriptions < Base
    private

    def headers(csv)
      csv.headers do |csv_header|
        user_columns = %i(id email firstname lastname card_reference)
        subscription_columns = %i(state start_at end_at created_at replaced_date origin_location)
        subscription_plan_columns = %i(name description price_ati locations)

        csv_header.columns(*user_columns + subscription_columns + subscription_plan_columns)
        csv_header.mappings Hash[user_columns.map { |column_name| [column_name, User.human_attribute_name(column_name)] } +
                            subscription_plan_columns.map { |column_name| [column_name, SubscriptionPlan.human_attribute_name(column_name)] } +
                            subscription_columns.map { |column_name| [column_name, Subscription.human_attribute_name(column_name)] }
                            ]
      end
    end

    def rows(csv)
      csv.rows elements_to_csv do |csv_row, subscription|
        if subscription.user.present?
          map_user(csv_row, subscription.user)
        end
        if subscription.subscription_plan.present?
          map_plan(csv_row, subscription.subscription_plan)
        end
        csv_row.cells :state, :start_at, :end_at, :created_at, :origin_location, :replaced_date
      end
    end

    def map_user(csv_row, user)
      csv_row.cell :id, user.id
      csv_row.cell :email, user.email
      csv_row.cell :firstname, user.firstname
      csv_row.cell :lastname, user.lastname
      csv_row.cell :card_reference, user.card_reference
    end

    def map_plan(csv_row, plan)
      csv_row.cell :name, plan.name
      csv_row.cell :description, plan.description
      csv_row.cell :price_ati, plan.price_ati
      csv_row.cell :locations, plan.locations.join(', ')
    end
  end
end
