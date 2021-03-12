module CSVExporter
  # You will have to inherit from Base.
  class Base
    attr_accessor :elements_to_csv
    COLUMNS = { }

    def initialize(collection_to_csv)
      @elements_to_csv = collection_to_csv
    end

    def execute
      CsvShaper::Shaper.encode do |csv_content|
        headers(csv_content)
        rows(csv_content)
      end
    end

    private

    # You will have to  override this 2 methods to make another csv exporter
    # Beware I18n translations here do not work with the t() helper.
    # Use the full I18n.t('admin.exports.yourelement.yourword')

    def headers(csv)
      csv.headers do |csv_header|
        csv_header.columns(*self.class::COLUMNS.keys)
        csv_header.mappings self.class::COLUMNS
      end
    end

    def rows(csv)
      csv.rows elements_to_csv do |csv_row, element|
      end
    end
  end
end
