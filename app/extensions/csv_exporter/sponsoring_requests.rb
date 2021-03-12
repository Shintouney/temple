module CSVExporter
  class SponsoringRequests < Base
    private

      COLUMNS = {
        firstname: 'Prénom',
        lastname: 'Nom',
        phone: 'Téléphone',
        email: 'Email',
        user: 'Parrain'
      }

    def rows(csv)
      csv.rows elements_to_csv do |csv_row, sponsoring_request|
        sponsor_user = sponsoring_request.user
        csv_row.cell :user, "#{sponsor_user.lastname} #{sponsor_user.firstname}" if sponsor_user.present?
        csv_row.cells :firstname, :lastname, :phone, :email
      end
    end
  end
end
