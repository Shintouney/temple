module CSVExporter
  class UnsubscribeRequests < Base
    private

      COLUMNS = {
        firstname: 'Prénom',
        lastname: 'Nom',
        phone: 'Téléphone',
        email: 'Email',
        desired_date: 'Date souhaitée',
        health_reason: 'Raison de santé',
        moving_reason: 'Raison de mobilité',
        other_reason: 'Autre raison'
      }

    def rows(csv)
      csv.rows elements_to_csv do |csv_row, unsubscribe_request|
        csv_row.cells :firstname, :lastname, :phone, :email, :desired_date, :health_reason, :moving_reason, :other_reason
      end
    end
  end
end
