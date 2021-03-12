module CSVExporter
  class LessonRequests < Base
    private

      COLUMNS = {
        first_coach_name: 'Prénom',
        second_coach_name: 'Nom',
        comment: 'Téléphone',
        user: 'Membre',
      }

    def rows(csv)
      csv.rows elements_to_csv do |csv_row, lesson_request|
        csv_row.cell :user, lesson_request.user.email
        csv_row.cells :first_coach_name, :second_coach_name, :comment
      end
    end
  end
end
