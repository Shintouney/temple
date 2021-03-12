module Slimpay
  class ErrorParser

    # Constants for CSV rows lines
    # REFERENCE = 1
    # EMAIL = 5
    # NAME = 4
    # RUM = 21
    REF_TRANSACTION = 2
    ERROR_LABEL = 15
    ERROR_TYPE = 17
    ERROR_CODE = 19
    ERROR_DESCRIPTION = 20
    ERROR_AMOUNT = 8

    # Constants for CSV codes
    BOF = 0
    EOF = 9

    def initialize(file_path)
      @csv = CSV.open(file_path, col_sep: ';')
    end

    def execute
      @csv_array = @csv.readlines
      @first_row = @csv_array.first
      @last_row = @csv_array.last

      unless @first_row.first.to_i.eql?(BOF)
        log_error(@first_row, 1)
        return
      end
      unless @last_row.first.to_i.eql?(EOF)
        log_error(@last_row, @csv_array.size)
        return
      end
      process_errors
    end

    private

    def process_errors
      @csv_array.each_with_index do |row, index|
        next if index.eql?(BOF) || index.eql?(EOF)
        begin
          @payment = process_payment(row)
          next if @payment.nil?

          log_transaction(row, index + 1)
        rescue StandardError => e
          log_error(row, index + 1, e)
        end
      end
    end

    def process_payment(row)
      payment = Payment.find(row[REF_TRANSACTION])
      return if payment.nil?
      payment.decline!
      comment = "#{ row[ERROR_TYPE] } #{ row[ERROR_CODE] } #{ row[ERROR_DESCRIPTION] } << #{ row[ERROR_LABEL] } >> #{ row[ERROR_AMOUNT] } €"
      payment.update_attribute :comment, comment

      if payment.invoices.first.payments.with_state(:declined).count < 2
        handle_failed_payment(payment.invoices.first)
      else
        handle_failed_payment_retry(payment.invoices.first)
      end
      payment
    end

    def handle_failed_payment(invoice)
      invoice.wait_for_payment_retry!

      update_invoice(invoice)
    end

    def handle_failed_payment_retry(invoice)
      invoice.wait_for_payment!
      forbid_user_card_access(invoice.user)

      AdminMailer.monthly_subscription_payment_retry_failed(invoice.user.id).deliver_later

      update_invoice(invoice)
    end

    def update_invoice(invoice)
      invoice.subscription_period_start_at = Date.today if invoice.subscription_period_start_at.blank?
      invoice.subscription_period_end_at = Date.today if invoice.subscription_period_end_at.blank?
      invoice.next_payment_at = Date.today if invoice.next_payment_at.blank?
      invoice.update_attributes(next_payment_at: invoice.next_payment_at + Invoice::Deferred::Charge::RETRY_PAYMENT_DELAY)      
    end

    def forbid_user_card_access(user)
      unless user.card_access.forced_authorized?
        user.update_attributes(card_access: :forbidden)
        ResamaniaApi::PushUserWorker.perform_async(user.id)
      end
    end

    def log_transaction(row, line)
      log_file = File.open('log/sepa_payments.rtrans.log', 'a+')
      log_file.write("SEPA ERROR LOGGED AT LINE #{line} : #{row}\n")
      log_file.close
    end

    def log_error(row, line, exception = nil)
      log_file = File.open('log/sepa_payments.error.log', 'a+')
      log_file.write("==> ERROR LOGGED AT LINE #{line} : #{exception.message if exception.present?} ----> #{row}\n")
      log_file.close
    end
  end
end
