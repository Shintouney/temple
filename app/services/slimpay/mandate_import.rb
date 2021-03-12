module Slimpay
  class MandateImport

    # Constants for CSV rows lines
    REFERENCE = 1
    EMAIL = 4
    # EMAIL = 5
    # FULL_NAME = 4
    RUM = 20
    MANDATE_CREATED_AT = 21

    # Constants for CSV codes
    BOF = 0
    BOF_DATE = 7
    SEPA_IMPORT = 8
    EOF = 9

    # Constants for parsing use
    FULL_NAME_ARRAY_MAX_SIZE = 2

    def initialize(file_path)
      @csv = CSV.open(file_path, col_sep: ';')
    end

    def execute
      @csv_array = @csv.readlines
      @first_row = @csv_array.first
      @last_row = @csv_array.last
      @given_date = @csv_array.first[BOF_DATE]
      unless @first_row.first.to_i.eql?(BOF)
        log_error(@first_row, 1)
        return
      end
      unless @last_row.first.to_i.eql?(EOF)
        log_error(@last_row, @csv_array.size)
        return
      end
      process_mandates
    end

    private

    def process_mandates
      @csv_array.each_with_index do |row, index|
        next if row.eql?(@first_row) || row.eql?(@last_row)
        next if row.first.to_i != SEPA_IMPORT
        @user = find_user(row)
        if @user.nil? || @user.is_a?(Array) || row[RUM].blank?
          log_error(row, index + 1)
          next
        end
        create_mandate(row)
      end
    end

    def find_user(row)
      return User.find_by(id: row[REFERENCE].to_i) unless row[REFERENCE].blank?
      return User.find_by(email: row[EMAIL]) unless row[EMAIL].blank?
      # return if row[FULL_NAME].blank?
      # full_name = row[FULL_NAME].split(' ')
      # return if full_name.size > FULL_NAME_ARRAY_MAX_SIZE
      # User.where("upper(firstname) = ? AND upper(lastname) = ?", full_name.first, full_name.last).first
    end

    def create_mandate(row)
      @user.mandates.create(slimpay_order_state: ::Mandate::SLIMPAY_ORDER_COMPLETED,
                           slimpay_state: ::Mandate::SLIMPAY_STATE_CREATED,
                           slimpay_rum: row[RUM],
                           slimpay_created_at: row[MANDATE_CREATED_AT] || @given_date
                           )
    end

    def log_error(row, line)
      log_file = File.open('log/mandates.error.log', 'a+')
      log_file.write("#{Time.now}===> IMPORT ERROR AT LINE #{line} : #{row}\n")
      log_file.close
    end
  end
end
